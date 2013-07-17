#! ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'legal_markdown/version.rb'
require 'legal_markdown/make_yaml_frontmatter.rb'
require 'legal_markdown/legal_to_markdown.rb'

module LegalMarkdown

  def self.parse(*args)
    args = ARGV.dup
    if(!args[0])
      STDERR.puts "Sorry, I didn't understand that. Please give me your legal_markdown filenames or \"-\" for stdin."
      exit 0
    elsif args.include?("--headers")
      MakeYamlFrontMatter.new(args)
    elsif args.include?("--to-json") || args[-1][/\.json/]
      LegalToMarkdown.parse_jason(args)
    else
      LegalToMarkdown.parse_markdown(args)
    end
  end
end

LegalMarkdown::parse(ARGV)