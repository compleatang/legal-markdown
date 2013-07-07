class MakeYamlFrontMatter

  def initialize(*args)
    ARGV.include?("-") ? data = STDIN.read : data = load(*args)
    parsed_file = find_yaml_if_yaml(data)
    new_yaml_as_array = scan_and_filter_yaml(parsed_file[0], parsed_file[1])
    parsed_file.shift
    new_yaml = build_new_yaml_frontmatter(new_yaml_as_array)
    new_yaml_as_array.clear
    write_it( new_yaml + parsed_file[0] )
  end

  def load(*args)
    @file = ARGV[-1]
    source_file = File::read(@file) if File::exists?(@file) && File::readable?(@file)
  end

  def find_yaml_if_yaml(source)
    yaml_pattern = /\A---\s*\n(.*?\n?)^---\s*$\n?/m
    if source[yaml_pattern]
      data = YAML.load($1)
      content = $POSTMATCH
    else
      data = {}
      content = source
    end
    return [data, content]
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
    pandoc_headrs = %w{title, author, date}
    mixins = filter_yaml(yaml_data, scan_doc(content, mixin_pattern))
    opt_clauses = filter_yaml(yaml_data, scan_doc(content, opt_clauses_pattern))
    levels = filter_yaml(yaml_data, scan_doc(content, @structured_headers_pattern).concat(%w{no-indent no-reset}))
    # pandoc = pandoc_headrs.inject({}){|h,e| h.merge({e => yaml_data[e]}) if yaml_data.has_key?(e) }
    return [mixins, opt_clauses, levels]
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
      yaml_data_as_array[2].each{ |head, val| front << head + ": " + val.to_s + "\n" }
    end
    if yaml_data_as_array[3]
      front << "\n\# Pandoc Specific\n"
      yaml_data_as_array[3].each{ |head, val| front << head + ": " + val.to_s + "\n" }
    end
    front << "\n---\n\n"
  end

  def write_it( final_content )
    if @file
      File.open(output_file, "w") {|f| f.write( final_content ) }
    else 
      STDOUT.write final_content
    end
  end
end
