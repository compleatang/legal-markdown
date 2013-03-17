#! ruby
require 'yaml'
require 'English'
require 'roman-numerals'
require "legal_markdown/version"

module LegalMarkdown
  extend self

  def markdown_to_legal(*args)
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
    file = write_it( @output_file, headed_content )
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

    # Load Source File
    @output_file = ARGV[-1]
    @input_file = ARGV[-2] ? ARGV[-2] : ARGV[-1]
    source_file = File::read(@input_file) if File::exists?(@input_file) && File::readable?(@input_file)
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

    def clauses_mixins( mixins, content )
      clauses_to_delete = []
      clauses_to_mixin = []
      
      mixins.each do | mixin, replacer |
        replacer = replacer.to_s.downcase
        clauses_to_delete << mixin if replacer == "false"
        clauses_to_mixin << mixin if replacer == "true"
      end
      
      clauses_to_delete.each { |m| mixins.delete(m) }
      clauses_to_mixin.each { |m| mixins.delete(m) }

      until clauses_to_delete.size == 0
        clauses_to_delete.each do | mixin |
          pattern = /(\[{{#{mixin}}}\s*)(.*?\n?)(\])/m
          sub_pattern = /\[{{(\S+)}}/m
          content[pattern]
          get_it_all = $& || ""
          sub_clause = $2 || ""
          next if sub_clause[sub_pattern] && clauses_to_delete.include?($1)
          content = content.gsub( get_it_all, "" )
          clauses_to_delete.delete( mixin ) unless content[pattern]
        end
      end

      until clauses_to_mixin.size == 0
        clauses_to_mixin.each do | mixin |
          pattern = /(\[{{#{mixin}}}\s*)(.*?\n?)(\])/m
          sub_pattern = /(\[{{\S+}})/m
          content[pattern]
          get_it_all = $& || ""
          sub_clause = $2 || ""
          next if sub_clause[sub_pattern] && clauses_to_mixin.include?($1)
          content = content.gsub( get_it_all, sub_clause )
          clauses_to_mixin.delete( mixin ) unless content[pattern]
        end
      end

      return [content, mixins]
    end

    def normal_mixins( mixins, content )
      mixins.each do | mixin, replacer |
        unless mixin =~ /level-\d/ or mixin =~ /no-reset/ or mixin =~ /no-indent/
          replacer = replacer.to_s
          safe_words = [ "title", "author", "date" ]
          pattern = /({{#{mixin}}})/
          if content =~ pattern
            content = content.gsub( $1, replacer )
            mixins.delete( mixin ) unless safe_words.any?{ |s| s.casecmp(mixin) == 0 }
          end
        end
      end
      return [content, mixins]
    end

    clauses_mixed = clauses_mixins( mixins, content )
    mixed = normal_mixins( clauses_mixed[1], clauses_mixed[0] )
    return [ mixed[0], mixed[1] ]
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
        if value =~ /I\.\z/            # type1 : {{ I. }}
          return[:type1, value[0..-3]]
        elsif value =~ /\(I\)\z/       # type2 : {{ (I) }}
          return[:type2, value[0..-4]]
        elsif value =~ /i\.\z/         # type3 : {{ i. }}
          return[:type3, value[0..-3]]
        elsif value =~ /\(i\)\z/       # type4 : {{ (i) }}
          return[:type4, value[0..-4]]
        elsif value =~ /[A-Z]\.\z/     # type5 : {{ A. }}
          return[:type5, value[0..-3]]
        elsif value =~ /\([A-Z]\)\z/   # type6 : {{ (A) }}
          return[:type6, value[0..-4]]
        elsif value =~ /[a-z]\.\z/     # type7 : {{ a. }}
          return[:type7, value[0..-3]]
        elsif value =~ /\([a-z]\)\z/   # type8 : {{ (a) }}
          return[:type8, value[0..-4]]
        elsif value =~ /\(\d\)\z/      # type9 : {{ (1) }}
          return[:type9, value[0..-4]]
        else value =~ /\d\.\z/         # type0 : {{ 1. }} ... also default
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
        if header =~ /no-reset/
          no_subs_array = value.split(", ")
          no_subs_array.each{|e| substitutions[e][6] = :no_reset }
        end
        @no_indt_array = []
        if header =~ /no-indent/
          @no_indt_array = value.split(", ")
        end
      end

      return substitutions
    end

    def find_the_block( content )
      # finds the block of text that will be processed
      # returns an array with the first element as the block 
      # to be processed and the second element as the rest of the document
      if content =~ /(^```\s*\n?)(.*?\n?)(^```\s*\n?)/m
        block = $2.chomp
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
        if value[0] == :type1       # :type1 : {{ I. }}
          value[2..4] = [ "", "I", "." ]
          return value
        elsif value[0] == :type2    # :type2 : {{ (I) }}
          value[2..4] = [ "(", "I", ")"]
          return value
        elsif value[0] == :type3    # :type3 : {{ i. }}
          value[2..4] = [ "", "i", "."]
          return value
        elsif value[0] == :type4    # :type4 : {{ (i) }}
          value[2..4] = [ "(", "i", ")"]
          return value
        elsif value[0] == :type5    # :type5 : {{ A. }}
          value[2..4] = [ "", "A", "."]
          return value
        elsif value[0] == :type6    # :type6 : {{ (A) }}
          value[2..4] = [ "(", "A", ")"]
          return value
        elsif value[0] == :type7    # :type7 : {{ a. }}
          value[2..4] = [ "", "a", "."]
          return value
        elsif value[0] == :type8    # :type8 : {{ (a) }}
          value[2..4] = [ "(", "a", ")"]
          return value
        elsif value[0] == :type9    # :type9 : {{ (1) }}
          value[2..4] = [ "(", "1", ")"]
          return value
        else value[0] == :type0     # :type0 : {{ 1. }} ... also default
          value[2..4] = [ "", 1, "."]
          return value
        end
      end

      def log_the_line( new_block, selector, line, array_to_sub )
        substitute = array_to_sub[1..4].join
        spaces = ""
        unless @no_indt_array.include?(selector)
          downgrade_spaces = @no_indt_array.include?("l.") ? @no_indt_array.size - 1 : @no_indt_array.size
          spaces = ( " " * ( (selector.size) - 2 - downgrade_spaces ) * 4 )
        end
        line = line.gsub( $1, ( $1 + spaces ) ) if line[/(\n\n)/]
        new_block << spaces + line.gsub(selector, substitute) + "\n"
      end

      def increment_the_branch( hash_of_subs, array_to_sub, selector )
        romans_uppers = [ :type1, :type2 ]
        romans_lowers = [ :type3, :type4 ]
        romans = romans_uppers + romans_lowers
        if romans.any?{ |e| e == array_to_sub[0] }
          if romans_lowers.any?{ |e| e == array_to_sub[0] }
            r_l = true
          else
            r_u = true
          end
        end
        if r_l == true
          array_to_sub[3] = array_to_sub[3].upcase
        end
        if r_l == true || r_u == true
          array_to_sub[3] = RomanNumerals.to_decimal(array_to_sub[3]) 
        end
        array_to_sub[3] = array_to_sub[3].next
        if r_l == true || r_u == true
          array_to_sub[3] = RomanNumerals.to_roman(array_to_sub[3]) 
        end
        if r_l == true
          array_to_sub[3] = array_to_sub[3].downcase
        end
        hash_of_subs[selector]= array_to_sub
        return hash_of_subs
      end

      def reset_the_sub_branches( hash_of_subs, array_to_sub, selector )
        hash_of_subs = increment_the_branch( hash_of_subs, array_to_sub, selector )
        leaders_to_reset = []
        hash_of_subs.each_key{ |k| leaders_to_reset << k if k > selector }
        leaders_to_reset.each do | leader |
          unless hash_of_subs[leader][6] == :no_reset
            unless hash_of_subs[leader][5] == :pre
              hash_of_subs[leader]= get_the_subs_arrays(hash_of_subs[leader])
            else
              hash_of_subs[leader]= get_the_subs_arrays(hash_of_subs[leader])
              hash_of_subs[leader]= pre_setup(hash_of_subs[leader])
            end
          end
        end
        return hash_of_subs
      end

      def pre_setup( array_to_sub )
        array_to_sub[5] = :pre
        array_to_sub[1] = ""
        return array_to_sub
      end

      def reform_the_block( old_block, substitutions )
        # method will take the old_block and iterate through the lines.
        # First it will find the leading indicator. Then it will
        # find the appropriate substitution from the substitutions 
        # hash. After that it will rebuild the leading matter from the
        # sub hash. It will drop markers if it is going down the tree.
        # It will reset the branches if it is going up the tree. 
        # sub_it is an array w/ type[0] & lead_string[1] & id's[2..4]
        new_block = ""
        leader_before = ""
        leader_above = ""
        selector_before = "" 
        temp_block = []
        old_block.each_line{ |l| old_block.gsub(l, "") if l[/^\n/] }
        old_block.each_line{ |l| l[/(^l+.\s)/] ? temp_block << l : temp_block.last << ("\n" + l) unless temp_block.empty? }
        old_block = temp_block
        temp_block = []
        old_block.each do | line | 
          line[/(^l+.\s)/]
          selector = $1.chop
          sub_it = substitutions[selector]
          sub_it[5] = "" if sub_it[5].nil?
          if sub_it[5] == :pre || sub_it[1] =~ /pre/
            sub_it = pre_setup(sub_it) 
            if selector_before < selector     # Going down the tree, into pre
              leader_above = substitutions[selector_before][1..4].join
              sub_it[1] = leader_above = leader_before
            elsif selector_before > selector && substitutions[selector_before][5] == :pre
              sub_it[1] = leader_above[0..-3]
            else
              sub_it[1] = leader_above
            end
          end
          log_the_line( new_block, selector, line, sub_it )
          leader_before = sub_it[1..4].join
          if selector_before > selector     # We are going up the tree.
            substitutions = reset_the_sub_branches(substitutions, sub_it, selector)
          else                              # We are at the same level.
            substitutions = increment_the_branch(substitutions, sub_it, selector)
          end
          selector_before = selector
        end
        return new_block
      end

      substitutions.each_key{ |k| substitutions[k]= get_the_subs_arrays(substitutions[k]) }
      new_block = reform_the_block( block, substitutions )
    end

    headers = get_the_substitutions( headers )
    block_noted = find_the_block( content )
    block = block_noted[0]
    not_the_block = block_noted[1]
    block_noted = ""   # Really only for long documents so they don't use too much memory

    if block == nil || block == ""
      block_redux = ""
    elsif headers == {} 
      block_redux = block
    else
      block_redux = chew_on_the_block( headers, block )
    end

    headed = not_the_block.gsub("{{block}}", block_redux ) 
  end

  # ----------------------
  # |      Step 6        |
  # ----------------------
  # Write the file 

  def write_it( output_file, final_content )
    File.open(output_file, "w") {|f| f.write( final_content ) }
  end
end