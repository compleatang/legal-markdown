module LegalToMarkdown
  extend self

  private

  # ----------------------
  # |      Step 1        |
  # ----------------------
  # Parse Options & Load File

  def load(args)
    @output_file = args[-1]
    @input_file = args[-2] ? args[-2] : args[-1]
    begin
      if @input_file != "-"
        source_file = File::read(@input_file) if File::exists?(@input_file) && File::readable?(@input_file)
      elsif @input_file == "-"
        source_file = STDIN.read
      end
      source_file.scan(/(@include (.+)$)/).each do |set|
        partial_file = set[1]
        to_replace = set[0]
        partial_contents = File::read(partial_file) if File::exists?(partial_file) && File::readable?(partial_file)
        source_file.gsub!(to_replace, partial_contents)
      end
      return source_file
    rescue => e
      puts "Sorry, I could not read the input file #{@input_file}: #{e.message}."
      exit 0
    end
  end
end