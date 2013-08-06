#!/usr/bin/env ruby
require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'securerandom'
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

  def teardown
    puts "\nAll Done!\n\n"
  end

  def get_file ( filename )
    contents = IO.read(filename)
    contents.rstrip
  end

  def create_temp(ending)
    temp_file = "/tmp/lmdtests-" + SecureRandom.hex + ending
  end

  def destroy_temp ( temp_file )
    File.delete temp_file if File::exists?(temp_file)
  end

  def the_content ( hash )
    hash["nodes"].each_value.collect{|v| v["data"]["content"] if v["data"] && v["data"]["content"]}.select{|v| v}
  end

  def test_bad_command_line_calls
    puts "Testing bad file name.\n\n"
    puts "Testing => legal2md -m 12345.lmd 12345.md"
    cmd = `legal2md -m 12345.lmd 12345.md`
    assert_equal( cmd, "Sorry, I could not read the file 12345.lmd: No such file or directory - 12345.lmd.\n" )
    puts "Testing => legal2md -m"
    cmd = `legal2md -m`
    assert_equal( cmd, "Sorry, I could not read the file to_markdown: can't convert Symbol into String.\n" )
    puts "Testing => legal2md 12345.md"
    cmd = `legal2md 12345.md`
    assert_equal( cmd, "Sorry, I could not read the file 12345.md: No such file or directory - 12345.md.\n" )
  end

  def test_good_command_line_calls
    puts "\n\nTesting the command line caller.\n\n"
    cmds = [ "--headers", "--to-markdown", "--to-json", '', '' ]
    file = "00.load_write_no_action.lmd"
    output = ['', create_temp('.md'), create_temp('.json'), create_temp('.md'), create_temp('.json')]
    puts "Testing => cat 00.load_write_no_action.lmd | legal2md - -"
    stdin_out_only = `cat 00.load_write_no_action.lmd | legal2md - -`
    assert_equal(get_file(file), stdin_out_only)
    cmds = cmds.each{|l| l << (" " + file) }.zip(output)
    cmds.each do |cmd|
      cmd = 'legal2md ' + cmd.join(' ')
      puts "Testing => #{cmd}"
      `#{cmd}`
      assert_equal(get_file(file), get_file('00.load_write_no_action.md'))
    end
  end

  def test_markdown_files
    puts "\n\nTesting lmd to markdown files.\n\n"
    @lmdfiles.each do | lmd_file |
      puts "Testing => #{lmd_file}"
      temp_file = create_temp('.md')
      benchmark_file = File.basename(lmd_file, ".lmd") + ".md"
      LegalMarkdown.parse( :to_markdown, lmd_file, temp_file )
      assert_equal(get_file(benchmark_file), get_file(temp_file), "This file threw an exception => #{lmd_file}")
      destroy_temp temp_file
    end
  end

  def test_the_json_files
    puts "\n\nTesting lmd to json files.\n\n"
    @lmdfiles.each do | lmd_file |
      puts "Testing => #{lmd_file}"
      temp_file = create_temp('.json')
      benchmark_file = File.basename(lmd_file, ".lmd") + ".json"
      LegalMarkdown.parse( :to_json, lmd_file, temp_file )
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

  def test_yaml_headers
    puts "\n\nTesting Make YAML Frontmatter.\n\n"
    @lmdfiles.each do | lmd_file |
      puts "Testing => #{lmd_file}"
      temp_file = create_temp('.lmd')
      benchmark_file = File.basename(lmd_file, ".lmd") + ".headers"
      LegalMarkdown.parse( :headers, lmd_file, temp_file )
      assert_equal(get_file(benchmark_file), get_file(temp_file), "This file threw an exception => #{lmd_file}")
      destroy_temp temp_file
    end
  end
end