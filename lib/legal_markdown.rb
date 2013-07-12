#! ruby
require File.dirname(__FILE__) + '/legal_markdown/version'
require File.dirname(__FILE__) + '/legal_markdown/make_yaml_frontmatter.rb'
require File.dirname(__FILE__) + '/legal_markdown/legal_to_markdown.rb'

module LegalMarkdown

  def self.parse(*args)
    args = ARGV.dup
    if(!args[0])
      STDERR.puts "Sorry, I didn't understand that. Please give me your legal_markdown filenames or \"-\" for stdin."
      exit 0
    elsif args.include?("--headers")
      LegalMarkdown::MakeYamlFrontMatter.new(args)
    else
      LegalMarkdown::LegalToMarkdown.parse(args)
    end
  end
end