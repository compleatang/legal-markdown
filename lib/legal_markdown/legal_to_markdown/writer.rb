module LegalToMarkdown
  extend self

  def write_it( final_content )
    final_content = final_content.gsub(/ +\n/, "\n")
    if @output_file && @output_file != "-"
      File.open(@output_file, "w") {|f| f.write( final_content ); f.close }
    else
      STDOUT.write final_content
    end
  end
end