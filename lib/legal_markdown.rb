#! ruby
require 'yaml'
require 'English'
require "legal_markdown/version"

module LegalMarkdown
  extend self
  def execute(*args)
    # Get the Content & Yaml Data
    data = load(*args)
    parsed_content = parse_file(data[0])
    # Run the Mixins
    mixed_content = mixing_in(parsed_content[0], parsed_content[1])
    #REMOVE THESE LATER
    content = mixed_content[0]
    yaml_data = mixed_content[1]
    puts content
    puts "What's left"
    yaml_data.each{|k,v| puts "#{k}: #{v}"}
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
    source_file = File::read(ARGV[-1]) if File::exists?(ARGV[-1])
    return[source_file, '']
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
    return[data, content]
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
    return[content, mixins]
  end

  # ----------------------
  # |      Step 4        |
  # ----------------------
  # Headers


  #  Step 4a: Find the block starting and finishing lines


  #  Step 4b: Set the alignment and the nesting structure


  #  Step 4c: Set the requested list styling per the YAML front-matter


  #  Step 4d: Pull out the ll. tags & strip the leading whitespace
  #   but keep the proper nesting alignment.


  # ----------------------
  # |      Step 5        |
  # ----------------------
  # Special YAML fields


  # Step 6: Strip the YAML front-matter


  # Step 7: Write the file 


  #   Step 7a: Where an output file was specified


  #   Step 7b: Where an output file was not specified

end