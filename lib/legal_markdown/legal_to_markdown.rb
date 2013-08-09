$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'legal_to_markdown/load_source.rb'
require 'legal_to_markdown/mixins.rb'
require 'legal_to_markdown/leaders.rb'
require 'legal_to_markdown/json_builder.rb'
require 'legal_to_markdown/writer.rb'
require 'roman_numerals'
require 'paint'

module LegalToMarkdown

  def parse_markdown args, verbosity
    parse_setup args, verbosity
    source = FileToParse.new(@input_file, :markdown)
    parse_controller source
  end

  def parse_jason args, verbosity
    parse_setup args, verbosity
    source = FileToParse.new(@input_file, :jason)
    parse_controller source
  end

  private

  def parse_setup args, verbosity
    @input_file = args[-2] ? args[-2] : args[-1]
    @output_file = args[-1]
    @verbose = true if verbosity
  end

  def parse_controller source
    verbose_after_process source, 'loading'
    source.run_mixins if source.mixins
    verbose_after_process source, 'mixins'
    source.run_leaders if source.leaders
    verbose_after_process source, 'headers'
    source.build_jason if source.writer == :jason
    write_it(source.content, source.writer)
  end

  def verbose_after_process source, action
    if @verbose
      puts
      puts Paint["Here's what I found after running the #{action}.", :blue, :bold]
      puts Paint['=============================================', :blue]
      puts
      puts Paint["The Headers I found are:", :green, :bold]
      puts Paint['------------------------', :green]
      puts Paint[(source.headers), :magenta]
      puts
      puts Paint["The Content I found is:", :green, :bold]
      puts Paint['-----------------------', :green]
      puts Paint[(source.content), :yellow]
      if action == 'loading'
        puts
        puts Paint["There are MIXINS to be parsed.", :red, :bold] if source.mixins
        puts Paint["There are STRUCTURED HEADERS to be parsed.", :red, :bold] if source.leaders
      end
    end
  end
end