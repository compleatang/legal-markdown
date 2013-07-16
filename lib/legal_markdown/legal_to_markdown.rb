$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'legal_to_markdown/load_source.rb'
require 'legal_to_markdown/mixins.rb'
require 'legal_to_markdown/leaders.rb'
require 'legal_to_markdown/json_builder.rb'
require 'legal_to_markdown/writer.rb'
require 'roman_numerals'

module LegalToMarkdown

  def parse_markdown(args)
    @input_file = args[-2] ? args[-2] : args[-1]
    @output_file = args[-1]
    source = FileToParse.new(@input_file, "markdown")
    source.run_mixins if source.mixins
    source.run_leaders if source.leaders
    write_it(source.content, source.writer)
  end

  def parse_jason(args)
    @input_file = args[-2] ? args[-2] : args[-1]
    @output_file = args[-1]
    source = FileToParse.new(@input_file, "jason")
    source.run_mixins if source.mixins
    source.run_leaders if source.leaders
    source.build_jason
    write_it(source.content, source.writer)
  end
end