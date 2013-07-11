#! ruby
require 'yaml'

class MakeYamlFrontMatter

  def initialize(*args)
    data = load(*args)
    parsed_file = find_yaml_if_yaml(data)
    new_yaml_as_array = scan_and_filter_yaml(parsed_file[0], parsed_file[1])
    new_yaml = build_new_yaml_frontmatter(new_yaml_as_array)
    write_it( new_yaml + parsed_file[1] )
  end

  def load(*args)
    begin
      @file = ARGV[-1]
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
    begin
      yaml_pattern = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      parts = source.partition( yaml_pattern )
      if parts[1] != ""
        headers = YAML.load(parts[1])
        content = parts[2]
      else
        headers = {}
        content = source
      end
    rescue => e
      puts "Sorry, something went wrong when I was loading the YAML front matter: #{e.message}."
    end
    return [headers, content]
  end

  def scan_doc(content, pattern)
    headers = content.scan(pattern).uniq.sort.flatten
    if pattern == @structured_headers_pattern
      headers = convert_ll_to_level_two(headers)
    end
    return headers
  end

  def convert_ll_to_level_two(levels)
    # receives an array in form ["l.", "ll.", "lll."] returns array in form ["level-1", "level-2"]
    levels.inject([]){|arr, level| level[/(l+)./]; arr << "level-" + $1.length.to_s}
  end

  def filter_yaml(yaml_data, stuff)
    # yaml_data will be a hash, stuff is an array, returns a filtered hash
    stuff_in_yaml = stuff.inject({}) do |hash, elem|
      yaml_data.has_key?(elem) ? hash.merge({elem => yaml_data[elem]}) : hash.merge({elem => ""})
    end
  end

  def scan_and_filter_yaml(yaml_data, content)
    mixin_pattern = /[^\[]{{(\S+)}}/
    opt_clauses_pattern = /\[{{(\S+)}}/
    @structured_headers_pattern = /(^l+.)/
    mixins = filter_yaml(yaml_data, scan_doc(content, mixin_pattern))
    opt_clauses = filter_yaml(yaml_data, scan_doc(content, opt_clauses_pattern))
    levels = filter_yaml(yaml_data, scan_doc(content, @structured_headers_pattern))
    extras = filter_yaml(yaml_data, %w{no-indent no-reset level-style})
    return [mixins, opt_clauses, levels, extras]
  end

  def build_new_yaml_frontmatter(yaml_data_as_array)
    front = "---\n\n"
    if yaml_data_as_array[0]
      front << "\# Mixins\n"
      yaml_data_as_array[0].each{ |head, val| front << head + ": " + val.to_s + "\n" }
    end
    if yaml_data_as_array[1]
      front << "\n\# Optional Clauses\n"
      yaml_data_as_array[1].each{ |head, val| front << head + ": " + val.to_s + "\n" }
    end
    if yaml_data_as_array[2]
      front << "\n\# Structured Headers\n"
      yaml_data_as_array[2].each{ |head, val| front << head + ": \"" + val.to_s + "\"\n" }
    end
    if yaml_data_as_array[3]
      yaml_data_as_array[3].each{ |head, val| front << head + ": " + val.to_s + "\n" }
    end
    front << "\n---\n\n"
  end

  def write_it( final_content )
    final_content.scan(/(\[PARTIALSTART\].*?\[PARTIALENDS\]\[(.*?)\])/m).each do |set|
      replacer = set[1]
      to_replace = set[0]
      final_content.gsub!(to_replace, replacer)
    end
    if @file != "-"
      File.open(@file, "w") {|f| f.write( final_content ) }
    else
      STDOUT.write final_content
    end
  end
end
