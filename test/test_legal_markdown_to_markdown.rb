#! ruby
require 'test/unit'
require 'tempfile'
require_relative '../lib/legal_markdown.rb'

class TestLegalMarkdownToMarkdown < Test::Unit::TestCase
  # test loading of invalid file
  # test no args in ARGV => raise error.
  # load all the .lmd files in the tests folder into an array
  # run the first file through gem...LegalToMarkdown.main(input_file, output_file)
  # output file to tmp dir.
  # compare the tmp file to the .md file from the hash (the baseline) ... diff
  # if assert_equal is false then stop....

  def setup
    Dir.chdir "./tests"
    @lmdfiles = Dir.glob"*.lmd"
    @lmdfiles.sort!
  end

  def get_file ( filename )
    contents = File::read( filename )
    return contents
  end

  def create_temp
    temp_file = Tempfile.new('lmd_tests')
    return temp_file.path
  end

  def destroy_temp ( temp_file )
    File.delete temp_file
  end

  def test_files
    @lmdfiles.each do | lmd_file |
      temp_file = create_temp
      benchmark_file = File.basename(lmd_file, ".lmd") + ".md"
      LegalToMarkdown.new( [ lmd_file, temp_file ] )
      assert_equal(get_file(benchmark_file).chomp, get_file(temp_file).chomp, "This file through an error => #{benchmark_file}")
      destroy_temp temp_file
    end
  end
end