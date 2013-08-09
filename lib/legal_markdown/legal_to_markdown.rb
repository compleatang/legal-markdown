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
    verbose_after_load source
    source.run_mixins if source.mixins
    verbose_after_mixins source
    source.run_leaders if source.leaders
    verbose_after_leaders source
    source.build_jason if source.writer == :jason
    write_it(source.content, source.writer)
  end

  def verbose_after_load source
    if @verbose
      puts
      puts Paint["Here's what I found after loading.", :blue, :bold]
      puts Paint['==================================', :blue]
      verbose_headers source
      verbose_content source
      puts
      puts Paint["There are MIXINS to be parsed.", :red, :bold] if source.mixins
      puts Paint["There are STRUCTURED HEADERS to be parsed.", :red, :bold] if source.leaders
    end
  end

  def verbose_after_mixins source
    if @verbose
      puts
      puts Paint["Here's what I found after running the mixins.", :blue, :bold]
      puts Paint['============================================', :blue]
      verbose_headers source
      verbose_content source
    end
  end

  def verbose_after_leaders source
    if @verbose
      puts
      puts Paint["Here's what I found after running the headers.", :blue, :bold]
      puts Paint['=============================================', :blue]
      verbose_headers source
      verbose_content source
    end
  end

  def verbose_headers source
    puts
    puts Paint["The Headers I found are:", :green, :bold]
    puts Paint['------------------------', :green]
    puts Paint[(source.headers), :magenta]
  end

  def verbose_content source
    puts
    puts Paint["The Content I found is:", :green, :bold]
    puts Paint['-----------------------', :green]
    puts Paint[(source.content), :yellow]
  end
end