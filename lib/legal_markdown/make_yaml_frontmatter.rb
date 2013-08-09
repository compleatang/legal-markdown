#! ruby
require 'yaml'

class MakeYamlFrontMatter

  def initialize(args)
    @input_file = args[-2] ? args[-2] : args[-1]
    @output_file = args[-1]
    find_yaml_if_yaml load
    scan_and_filter_yaml
    build_new_yaml_frontmatter unless @yaml_data_as_array == [{},{},{},{}]
    write_it
  end

  private

  def load
    begin
      source_file = @input_file == "-" ? STDIN.read : File::read(@input_file)
      source_file = guard_partials_start source_file
      source_file.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '')
      source_file.gsub!("\xC3\xAF\xC2\xBB\xC2\xBF".force_encoding("UTF-8"), '')
      source_file
    rescue
      puts "Sorry, I could not read the input file #{@input_file}."
      exit 0
    end
  end

  def find_yaml_if_yaml source
    yaml_pattern = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
    parts = source.partition yaml_pattern
    if ! parts[1].empty?
      parts[1] = guard_strings parts[1]
      @headers = YAML.load parts[1]
      @content = parts[2]
    else
      @headers = {}
      @content = source
    end
  end

  def scan_and_filter_yaml
    mixin_pattern = /[^\[]{{(\S+)}}/
    opt_clauses_pattern = /\[{{(\S+)}}/
    @structured_headers_pattern = /(^l+\.|^l\d+\.)/
    @yaml_data_as_array = []
    @yaml_data_as_array << ( filter_yaml mixin_pattern || {} )
    @yaml_data_as_array << ( filter_yaml opt_clauses_pattern || {} )
    @yaml_data_as_array << ( filter_yaml @structured_headers_pattern || {} )
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
    guard_partials_finish
    if @output_file && @output_file != "-"
      File.open(@output_file, "w") {|f| f.write( @content ); f.close }
    else
      STDOUT.write @content
    end
  end

  def filter_yaml pattern
    # @headers will be a hash, stuff is an array, returns a filtered hash
    stuff = pattern.is_a?(Regexp) ? scan_doc(pattern) : pattern
    if stuff
      stuff_in_yaml = stuff.inject({}) do |hash, elem|
        @headers.has_key?(elem) ? hash.merge({elem => @headers[elem]}) : hash.merge({elem => ""})
      end
    end
  end

  def scan_doc pattern
    found = @content.scan(pattern).uniq.sort.flatten
    if pattern == @structured_headers_pattern
      found = convert_ll_to_level_two found
    end
    found
  end

  def convert_ll_to_level_two levels
    # receives an array in form ["l.", "ll.", "lll."] returns array in form ["level-1", "level-2"]
    levels.inject([]) do |arr, level|
      level[/((l+)\.)|(l(\d+)\.*)/]
      if $2
        arr << "level-" + $2.length.to_s
      else
        arr << "level-" + $&.delete("l")
      end
    end
  end

  def sink_it section
    section.inject("") do |string, head|
      string << head[0] + ": \"" + ( head[1].to_s.gsub("\"", "\\\"") || "" ) + "\"\n"
      string
    end
  end

  def guard_partials_start source_file
    source_file.scan(/(@include (.+)$)/).each do |set|
      partial_file = set[1]
      to_replace = set[0]
      partial_contents = File::read(partial_file) if File::exists?(partial_file) && File::readable?(partial_file)
      source_file.gsub!(to_replace, "[PARTIALSTART]\n" + partial_contents + "\n[PARTIALENDS][#{to_replace}]")
    end
    source_file
  end

  def guard_strings strings
    strings.scan(/\:(\S.*)$/){ |m| strings = strings.gsub( m[0], " " + m[0] ) }
    strings.scan(/^((level-\d+:)(.+)\"*)$/) do |m|
      line = m[0]; level = m[1]; field = m[2]
      if field !=~ /(.+)\.\z/ || field !=~ /(.+)\)\z/
        strings = strings.gsub(line, level + " " + field.lstrip + ".")
      end
    end
    strings.scan(/(:\s*(\d+\.))$/){ |m| strings = strings.gsub( m[0], ": \"" + m[1] + "\"" ) }
    strings
  end

  def guard_partials_finish
    @content.scan(/(\[PARTIALSTART\].*?\[PARTIALENDS\]\[(.*?)\])/m).each do |set|
      replacer = set[1]
      to_replace = set[0]
      @content.gsub!(to_replace, replacer)
    end
  end
end
