module LegalToMarkdown
  extend self

  def write_it( final_content, writer )
    final_content = final_content.gsub(/ +\n/, "\n") if writer == :markdown
    require 'json' if writer == :jason
    if @output_file && @output_file != "-"
      File.open(@output_file, "w") {|f| f.write( final_content ); f.close } if writer == :markdown
      File.open(@output_file, "w") { |f| JSON.dump(final_content, f); f.close } if writer == :jason
    else
      STDOUT.write final_content
    end
  end
end