#! ruby
require 'test/unit'
require 'tempfile'
require 'json'
require 'legal_markdown'

class TestLegalMarkdownToMarkdown < Test::Unit::TestCase
  # load all the .lmd files in the tests folder into an array
  # run the first file through gem...LegalToMarkdown.main(input_file, output_file)
  # output file to tmp dir.
  # compare the tmp file to the .md file from the hash (the baseline) ... diff
  # if assert_equal is false then stop....

  def setup
    Dir.chdir File.dirname(__FILE__) + "/tests"
    @lmdfiles = Dir.glob "*.lmd"
    @lmdfiles.sort!
  end

  def get_file ( filename )
    begin
      contents = File::read( filename ) if File::exists?(filename) && File::readable?(filename)
    rescue => e
      raise "Could not find file #{filename}: #{e.message}."
      contents = ""
    end
    if contents && contents != ""
      return contents.rstrip
    else
      return ""
    end
  end

  def create_temp
    temp_file = Tempfile.new('lmd_tests')
    return temp_file.path
  end

  def destroy_temp ( temp_file )
    File.delete temp_file if File::exists?(temp_file)
  end

  def the_content ( hash )
    hash["nodes"].each_value.collect{|v| v["data"]["content"] if v["data"] && v["data"]["content"]}.select{|v| v}
  end

  def test_markdown_files
    puts "\n\nTesting lmd to markdown files.\n\n"
    @lmdfiles.each do | lmd_file |
      puts "Testing => #{lmd_file}"
      temp_file = create_temp
      benchmark_file = File.basename(lmd_file, ".lmd") + ".md"
      LegalToMarkdown.parse_markdown( [ lmd_file, temp_file ] )
      assert_equal(get_file(benchmark_file), get_file(temp_file), "This file threw an exception => #{lmd_file}")
      destroy_temp temp_file
    end
  end

  def test_json_files
    puts "Testing lmd to json files.\n\n"
    @lmdfiles.each do | lmd_file |
      puts "Testing => #{lmd_file}"
      temp_file = create_temp
      benchmark_file = File.basename(lmd_file, ".lmd") + ".json"
      LegalToMarkdown.parse_jason( [ "--to-json", lmd_file, temp_file ])
      benchmark = JSON.parse(IO.read(benchmark_file))
      temp = JSON.parse(IO.read(temp_file))
      assert_not_equal(benchmark["id"], temp["id"])
      assert_equal(benchmark["nodes"]["document"], temp["nodes"]["document"], "This file threw an exception => #{lmd_file}")
      assert_equal(benchmark["nodes"].count, temp["nodes"].count, "This file threw an exception => #{lmd_file}")
      assert_not_equal(benchmark["nodes"]["content"]["nodes"], temp["nodes"]["content"]["nodes"], "This file threw an exception => #{lmd_file}")
      assert_equal(the_content(benchmark), the_content(temp), "This file threw an exception => #{lmd_file}")
      destroy_temp temp_file
    end
  end
end