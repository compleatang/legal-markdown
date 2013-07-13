require File.dirname(__FILE__) + '/legal_to_markdown/load_source.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/mixins.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/leaders.rb'
require File.dirname(__FILE__) + '/legal_to_markdown/writer.rb'
require File.dirname(__FILE__) + '/roman_numerals'

module LegalToMarkdown

  def parse_markdown(args)
    @input_file = args[-2] ? args[-2] : args[-1]
    @output_file = args[-1]
    source = FileToParse.new(@input_file)
    source.run_mixins if source.mixins
    source.run_leaders if source.leaders
    write_it(source.content)
  end

  def parse_jason(arg)
    require File.dirname(__FILE__) + '/legal_to_markdown/json_builder.rb'
    @input_file = args[-2] ? args[-2] : args[-1]
    @output_file = args[-1]
    source = FileToParse.new(@input_file)
    source.writer = :jason
    source.run_mixins if source.mixins
    source.run_leaders if source.leaders
    source.extend LegalToMarkdown::JasonBuilder
    source.build_jason
    write_it(source.content)
  end
end