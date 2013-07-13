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
      MakeYamlFrontMatter.new(args)
    else
      LegalToMarkdown.parse_markdown(args)
    end
  end
end

# if launched as a standalone program, not loaded as a module
LegalToMarkdown.parse if __FILE__ == $0