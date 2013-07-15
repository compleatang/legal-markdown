#! ruby
require 'yaml'

class MakeYamlFrontMatter

  def initialize(args)
    find_yaml_if_yaml(load(args))
    scan_and_filter_yaml
    build_new_yaml_frontmatter unless @yaml_data_as_array == [{},{},{},{}]
    write_it
  end

  def load(args)
    begin
      @file = args[-1]
      if @file != "-"
        source_file = File::read(@file) if File::exists?(@file) && File::readable?(@file)
      else
        source_file = STDIN.read
      end
      source_file.scan(/(@include (.+)$)/).each do |set|
        partial_file = set[1]
        to_replace = set[0]
        partial_contents = File::read(partial_file) if File::exists?(partial_file) && File::readable?(partial_file)
        source_file.gsub!(to_replace, "[PARTIALSTART]\n" + partial_contents + "\n[PARTIALENDS][#{to_replace}]")
      end
      return source_file
    rescue => e
      puts "Sorry, I could not read the input file #{@file}: #{e.message}."
      exit 0
    end
  end

  def find_yaml_if_yaml( source )
    yaml_pattern = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
    parts = source.partition( yaml_pattern )
    if parts[1] != ""
      @headers = YAML.load(parts[1])
      @content = parts[2]
    else
      @headers = {}
      @content = source
    end
  end

  def scan_and_filter_yaml
    mixin_pattern = /[^\[]{{(\S+)}}/
    opt_clauses_pattern = /\[{{(\S+)}}/
    @structured_headers_pattern = /(^l+.|^l\d+.)/
    @yaml_data_as_array = []
    @yaml_data_as_array << ( filter_yaml(scan_doc(mixin_pattern)) || {} )
    @yaml_data_as_array << ( filter_yaml(scan_doc(opt_clauses_pattern)) || {} )
    @yaml_data_as_array << ( filter_yaml(scan_doc(@structured_headers_pattern)) || {} )
    @yaml_data_as_array << ( @yaml_data_as_array.last.empty? ? {} : filter_yaml(%w{no-indent no-reset level-style}) )
  end

  def build_new_yaml_frontmatter
    @content = "\n---\n\n" + @content
    replacers = {0=>"Mixins", 1=>"Optional Clauses", 2=>"Structured Headers", 3=>"Properties"}
    stringy = @yaml_data_as_array.inject("") do |string, section|
      unless section.empty?
        string << "\n\# " + replacers[@yaml_data_as_array.index(section)] + "\n"
        string << sink_it(section)
      end
      string
    end
    @content = stringy + @content
    @content = "---\n" + @content
  end

  def write_it
    @content.scan(/(\[PARTIALSTART\].*?\[PARTIALENDS\]\[(.*?)\])/m).each do |set|
      replacer = set[1]
      to_replace = set[0]
      @content.gsub!(to_replace, replacer)
    end
    if @file != "-"
      File.open(@file, "w") {|f| f.write( @content ); f.close }
    else
      STDOUT.write @content
    end
  end

  def scan_doc(pattern)
    found = @content.scan(pattern).uniq.sort.flatten
    if pattern == @structured_headers_pattern
      found = convert_ll_to_level_two found
    end
    found
  end

  def convert_ll_to_level_two(levels)
    # receives an array in form ["l.", "ll.", "lll."] returns array in form ["level-1", "level-2"]
    levels.inject([]){|arr, level| level[/((l+)\.)|(l(\d+)\.*)/]; $2 ? arr << "level-" + $2.length.to_s : arr << "level-" + $&.delete("l")}
  end

  def filter_yaml(stuff)
    # @headers will be a hash, stuff is an array, returns a filtered hash
    if stuff
      stuff_in_yaml = stuff.inject({}) do |hash, elem|
        @headers.has_key?(elem) ? hash.merge({elem => @headers[elem]}) : hash.merge({elem => ""})
      end
    end
  end

  def sink_it(section)
    section.inject("") do |string, head|
      string << head[0] + ": \"" + ( head[1].to_s || "" ) + "\"\n"
      string
    end
  end
end
