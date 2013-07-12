module LegalToMarkdown
  extend self

  private

  # ----------------------
  # |      Step 2        |
  # ----------------------
  # Load YAML Front-matter

  def parse_file(source)
    require 'yaml'
    begin
      if source[/@today/]
        require 'date'
        d = Date.today.strftime("%-d %B, %Y")
        source.gsub!($&, d)
      end
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
end