#! ruby
require 'yaml'
require 'English'
require "legal_markdown/version"

module LegalMarkdown
  extend self

  def markdown_preprocess(*args)
    # Get the Content & Yaml Data
    data = load(*args)
    parsed_content = parse_file(data[0])
    # Run the Mixins
    mixed_content = mixing_in(parsed_content[0], parsed_content[1])
    # Run the Pandoc Title Block
    pandoc_content = pandoc_title_block( mixed_content[1] ) + mixed_content[0]
    # Run the Headers
    headed_content = headers_on(mixed_content[1], pandoc_content)
    # Write the file
    file = write_it( @filename, headed_content )
  end

  private
  # ----------------------
  # |      Step 1        |
  # ----------------------
  # Parse Options & Load File 
  def load(*args)

    # OPTIONS
    # OPTS = {}
    # op = OptionParser.new do |x|
    #     x.banner = 'cat <options> <file>'      
    #     x.separator ''

    #     x.on("-A", "--show-all", "Equivalent to -vET")               
    #         { OPTS[:showall] = true }      

    #     x.on("-b", "--number-nonblank", "number nonempty output lines") 
    #         { OPTS[:number_nonblank] = true }      

    #     x.on("-x", "--start-from NUM", Integer, "Start numbering from NUM")        
    #         { |n| OPTS[:start_num] = n }

    #     x.on("-h", "--help", "Show this message") 
    #         { puts op;  exit }
    # end
    # op.parse!(ARGV)

    # # Example code for dealing with multiple filenames -- but don't think we want to do this.
    # ARGV.each{ |fn| output_file(OPTS, fn) }

    # Load Source File
    @filename = ARGV[-1]
    source_file = File::read(@filename) if File::exists?(@filename) && File::readable?(@filename)
    return [source_file, '']
  end

  # ----------------------
  # |      Step 2        |
  # ----------------------
  # Load YAML Front-matter

  def parse_file(source)
    begin
      yaml_pattern = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      if source =~ yaml_pattern
        data = YAML.load($1)
        content = $POSTMATCH
      else
        data = {}
        content = source
      end
    rescue => e 
      puts "Error reading file #{File.join(ARGV[0])}: #{e.message}"
    end
    return [data, content]
  end

  # ----------------------
  # |      Step 3        |
  # ----------------------
  # Mixins

  def mixing_in( mixins, content )
    mixins.each do | mixin, replacer |
      replacer = replacer.to_s
      safe_words = [ "title", "author", "date" ]
      if replacer != "false"
        pattern = /{{#{mixin}}}/
        if content =~ pattern
          content = content.gsub( pattern, replacer )
          # delete the mixin so that later parsing of special mixins & headers is easier and faster
          mixins.delete( mixin ) unless safe_words.any?{ |s| s.casecmp(mixin) == 0 }
        end
      end
    end
    return [content, mixins]
  end

  # ----------------------
  # |      Step 4        |
  # ----------------------
  # Special YAML fields

  def pandoc_title_block( headers )
    title_block = ""
    headers.each do | header |
      if header[0].casecmp("title") == 0
        title_block << "% " + header[1] + "\n"
        headers.delete( header )
      elsif header[0].casecmp("author") == 0
        title_block << "% " + header[1] + "\n"
        headers.delete( header )
      elsif header[0].casecmp("date") == 0
        title_block << "% " + header[1] + "\n\n"
        headers.delete( header )
      end
    end
    return title_block
  end

  # ----------------------
  # |      Step 5        |
  # ----------------------
  # Headers

  def headers_on( headers, content )

    def get_the_substitutions( headers )
      # find the headers in the remaining YAML 
      # parse out the headers into level-X and pre-X headers
      # then combine them into a coherent package
      # returns a hash with the keys as the l., ll. searches
      # and the values as the replacements in the form of 
      # an array where the first value is a symbol and the 
      # second value is the precursor

      def set_the_subs_arrays(value)
        # takes a core value from the hash pulled from the yaml
        # returns an array with a type symbol and a precursor string
        if value =~ /\(\d\)\z/ # type1 : {{ (1) }}
          return[:type1, value[0..-4]]
        elsif value =~ /[a-z]\.\z/ # type2 : {{ a. }}
          return[:type2, value[0..-3]]
        elsif value =~ /\([a-z]\)\z/ # type3 : {{ (a) }}
          return[:type3, value[0..-4]]
        elsif value =~ /[A-Z]\.\z/ # type4 : {{ A. }}
          return[:type4, value[0..-3]]
        elsif value =~ /\([A-Z]\)\z/ # type5 : {{ (A) }}
          return[:type5, value[0..-4]]
        elsif value =~ /I\.\z/ # type6 : {{ I. }}
          return[:type6, value[0..-3]]
        elsif value =~ /\(I\)\z/ # type7 : {{ (I) }}
          return[:type7, value[0..-4]]
        elsif value =~ /i\.\z/ # type8 : {{ i. }}
          return[:type8, value[0..-3]]
        elsif value =~ /\(i\)\z/ # type9 : {{ (i) }}
          return[:type9, value[0..-4]]
        else value =~ /\d\.\z/ # type0 : {{ 1. }} ... also default
          return[:type0, value[0..-3]]
        end
      end

      substitutions = {}
      headers.each do | header, value |
        if header =~ /level-\d/
          level = header[-1].to_i
          base = "l"
          search = base * level + "."
          # substitutions hash example {"ll."=>[:type8,"Article"],}
          substitutions[search]= set_the_subs_arrays(value.to_s)
        end
      end

      return substitutions
    end

    def find_the_block( content )
      # finds the block of text that will be processed
      # returns an array with the first element as the block 
      # to be processed and the second element as the rest of the document
      if content =~ /(^l+\.\s.+^$)/m
        block = $1.chomp
        content = $PREMATCH + "{{block}}\n" + $POSTMATCH
      end
      return[ block, content ]
    end

    def chew_on_the_block( substitutions, block )
      # takes a hash of substitutions to make from the #get_the_substitutions method
      # and a block of text returned from the #find_the_block method
      # iterates over the block to make the appropriate substitutions
      # returns a block of text

      def get_the_subs_arrays( value )
        # returns a new array for the replacements
        if value[0] == :type1       # :type1 : {{ (1) }}
          return[:type1, value[1], "(", "1", ")"]
        elsif value[0] == :type2    # :type2 : {{ a. }}
          return[:type2, value[1], "", "a", "."]
        elsif value[0] == :type3    # :type3 : {{ (a) }}
          return[:type3, value[1], "(", "a", ")"]
        elsif value[0] == :type4    # :type4 : {{ A. }}
          return[:type4, value[1], "", "A", "."]
        elsif value[0] == :type5    # :type5 : {{ (A) }}
          return[:type5, value[1], "(", "A", ")"]
        elsif value[0] == :type6    # :type6 : {{ I. }}
          return[:type6, value[1], "", "1", "."]   # TODO revert after installing the roman numerals gem
        elsif value[0] == :type7    # :type7 : {{ (I) }}
          return[:type7, value[1], "(", "1", ")"]  # TODO revert after installing the roman numerals gem
        elsif value[0] == :type8    # :type8 : {{ i. }}
          return[:type8, value[1], "", "1", "."]   # TODO revert after installing the roman numerals gem
        elsif value[0] == :type9    # :type7 : {{ (i) }}
          return[:type9, value[1], "(", "1", ")"]  # TODO revert after installing the roman numerals gem
        else value[0] == :type0     # :type0 : {{ 1. }} ... also default
          return[:type0, value[1], "", 1, "."]
        end
      end

      def log_the_line( new_block, selector, line, array_to_sub )
        subtitute = array_to_sub[1..-1].join
        spaces = ( " " * ( (selector.size) - 1 ) * 4 )
        new_block << spaces + line.gsub(selector, subtitute)
      end

      def increment_the_sub_branches( hash_of_subs, array_to_sub, selector )
        array_to_sub[3] = array_to_sub[3].next
        hash_of_subs[selector]= array_to_sub
        return hash_of_subs
      end

      def reset_the_sub_branches( hash_of_subs, array_to_sub, selector )
        hash_of_subs = increment_the_sub_branches( hash_of_subs, array_to_sub, selector )
        leaders_to_reset = []
        hash_of_subs.each_key{ |k| leaders_to_reset << k if k > selector }
        leaders_to_reset.each do | leader |
          #get_it = hash_of_subs[hash_key]
          hash_of_subs[leader]= get_the_subs_arrays(hash_of_subs[leader])
        end
        return hash_of_subs
      end

      def reform_the_block( old_block, substitutions )
        # method will take the old_block and iterate through the lines.
        # First it will find the leading indicator. Then it will
        # find the appropriate substitution from the substitutions 
        # hash. After that it will rebuild the leading matter from the
        # sub hash. It will drop markers if it is going down the tree.
        # It will reset the branches if it is going up the tree. 
        new_block = ""
        leader_above = ""
        selector_before = ""
        old_block.each_line do | line | 
          selector = $1.chop if line =~ /(^l+.\s)/ 
          # sub_it is an array w/ type[0] & lead_string[1] & id's[2..4]
          sub_it = substitutions[selector]
          if sub_it[1] == "{{pre}}" && leader_above != ""
            sub_it[1] = leader_above
          elsif sub_it[1] == "{{pre}}" && leader_above == ""
            sub_it[1] = ""
          end
          log_the_line( new_block, selector, line, sub_it )
          if selector_before > selector     # We are going up the tree.
            substitutions = reset_the_sub_branches(substitutions, sub_it, selector)
          elsif selector_before < selector  # We are going down the tree.
            leader_above = sub_it[1..-1].join
            substitutions = increment_the_sub_branches(substitutions, sub_it, selector)
          else                              # We are at the same level.
            substitutions = increment_the_sub_branches(substitutions, sub_it, selector)
          end
          selector_before = selector
        end
        return new_block
      end

      if block != nil && block != "" && substitutions != nil && substitutions != {}
        substitutions.each_key{ |k| substitutions[k]= get_the_subs_arrays(substitutions[k]) }
        new_block = reform_the_block( block, substitutions )
      end
    end

    headers = get_the_substitutions( headers )
    block_noted = find_the_block( content )
    block = block_noted[0]
    not_the_block = block_noted[1]
    block_noted = ""   # Really only for long documents so they don't use too much memory

    if headers == {} 
      block_redux = block
    elsif block == nil || block == ""
      block_redux = ""
    else
      block_redux = chew_on_the_block( headers, block )
    end

    headed = not_the_block.gsub("{{block}}", block_redux )
  end

  # ----------------------
  # |      Step 6        |
  # ----------------------
  # Write the file 

  def write_it( filename, final_content )
    if File.writable?( filename )
      File::open filename, 'w' do |f|
        f.write final_content
      end
    end
  end
end