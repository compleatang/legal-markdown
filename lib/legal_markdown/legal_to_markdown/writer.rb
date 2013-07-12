module LegalToMarkdown
  extend self

  private

  # ----------------------
  # |      Step 6        |
  # ----------------------
  # Write the file

  def write_it( final_content )
    final_content = final_content.gsub(/ +\n/, "\n")
    if @output_file && @output_file != "-"
      File.open(@output_file, "w") {|f| f.write( final_content ) }
    else
      STDOUT.write final_content
    end
  end
end