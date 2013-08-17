require 'pathname'
require 'yaml'

module Fixtureshelper

  def samples_path
    Pathname.new(File.dirname(__FILE__)).join('..','fixtures')
  end

  def lmd_files
    Dir[samples_path.join('*.lmd')].sort
  end

  def benchmark_file lmd_file, ext
    file = File.basename(lmd_file, 'lmd') + ext
    samples_path.join file
  end

  def cli_file
    samples_path.join '00.load_write_no_action.lmd'
  end

  def cli_md_benchmark
    samples_path.join '00.load_write_no_action.md'
  end

  def cli_json_benchmark
    samples_path.join '00.load_write_no_action.json'
  end

  def cli_debug_subj
    samples_path.join '42.block_with_opt_clauses_and_mixins.lmd'
  end

  def cli_debug_benchmark
    samples_path.join '42.block_with_opt_clauses_and_mixins.debug'
  end

  def cli_debug_recipient
    samples_path.join '42.block_with_opt_clauses_and_mixins.debugd'
  end

  def create_temp ending
    "/tmp/lmdtests-" + SecureRandom.hex + '.' + ending
  end

  def contents filename
    if File.extname(filename) == '.json'
      JSON.parse(IO.read(filename))
    else
      contents = IO.read filename
      contents.rstrip
    end
  end

  def the_content filename
    hash = contents filename
    hash["nodes"].each_value.collect{|v| v["data"]["content"] if v["data"] && v["data"]["content"]}.select{|v| v}
  end
end