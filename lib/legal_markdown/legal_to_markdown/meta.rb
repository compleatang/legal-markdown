module LegalToMarkdown
  extend self

  module Meta

    def run_meta
      default_output
      yaml_output if @writer == :markdown
      json_output if @writer == :jason
      no_output
    end

    def default_output
      case @writer
      when :markdown
        default = 'meta-yaml-output'
      when :jason
        default = 'meta-json-output'
      end
      if @orig_headers['meta']
        @orig_headers[default] = @orig_headers['meta']
        @orig_headers.delete('meta')
      end
    end

    def yaml_output
      if adder = @orig_headers['meta-yaml-output']
        adder = YAML.dump(adder)
        @content = adder + "---\n\n" + @content
      end
    end

    def json_output
      if adder = @orig_headers['meta-json-output']
        @docinfo = adder
      end
    end

    def no_output
      #hook for later processing
    end
  end
end