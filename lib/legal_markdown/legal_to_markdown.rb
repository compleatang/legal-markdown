require File.dirname(__FILE__) + '/legal_to_markdown/load_source.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/find_yaml.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/mixins.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/structured_headers.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/writer.rb'
require File.dirname(__FILE__) + '/roman_numerals'

module LegalToMarkdown

  def parse(args)
    data = load(args)                                              # Get the Content
    parsed_content = parse_file(data)                               # Load the YAML front matter
    mixed_content = mixing_in(parsed_content[0], parsed_content[1]) # Run the Mixins
    headed_content = headers_on(mixed_content[0], mixed_content[1]) # Run the Headers
    file = write_it( headed_content )                               # Write the file
  end
end