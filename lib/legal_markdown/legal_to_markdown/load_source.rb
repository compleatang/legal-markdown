module LegalToMarkdown
  extend self

  class FileToParse

    attr_accessor :headers, :content, :mixins, :leaders, :writer

    def initialize(file, output)
      @input_file = file; @headers = nil; @content = ""; @writer = output
      load; get_the_partials; parse; set_the_parsers
    end

    private

    def load
      if @input_file != "-"
        @content = get_file(@input_file)
      elsif @input_file == "-"
        @content = STDIN.read
      end
      if @content == nil
        puts "No input file or stdin specified. Please specify a file or \"-\" for stdin."
        exit 0
      end
    end

    def get_the_partials
      if @content[/^@include/]
        @content.scan(/^(@include (.+)$)/).each do |set|
          partial_file = set[1]
          to_replace = set[0]
          partial_contents = get_file partial_file
          @content.gsub!(to_replace, partial_contents)
        end
      end
    end

    def parse
      require 'yaml'
      today_is_the_day if @content[/@today/]
      yaml_pattern = /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      parts = @content.partition yaml_pattern
      if parts[1] != ""
        parts[1] = string_guard parts[1]
        @headers = YAML.load parts[1]
        @content = parts[2]
      end
    end

    def set_the_parsers
      if @content[/\{\{/] && @headers
        self.extend LegalToMarkdown::Mixins
        @mixins = true
      end
      if @content[/^```/] && @headers
        self.extend LegalToMarkdown::Leaders
        @leaders = true
      end
      if @writer == :jason
        self.extend LegalToMarkdown::JasonBuilder
      end
    end

    def get_file( file )
      begin
        f = File::read(file)
      rescue => e
        puts "Sorry, I could not read the file #{file}: #{e.message}."
        exit 0
      end
    end

    def today_is_the_day
      require 'date'
      d = Date.today.strftime("%-d %B, %Y")
      @content.gsub!(/@today/, d)
    end

    def string_guard strings
      if strings =~ /(:\s*(\d+\.))$/
        strings = strings.gsub($1, ": \"" + $2 + "\"" )
      end
      strings
    end
  end
end