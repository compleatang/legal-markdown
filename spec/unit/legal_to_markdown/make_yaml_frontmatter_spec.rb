#!/usr/bin/env ruby
require 'spec_helper'
include Fixtureshelper

describe "Makes YAML Headers" do
  lmd_files.each do |lmd_file|
    lmd = File.basename(lmd_file)
    it "should correctly parse #{lmd}" do
      benchmark = benchmark_file lmd_file, 'headers'
      result = create_temp 'headers'
      LegalMarkdown.parse( :headers, lmd_file, result )
      expect( contents result ).to eql( contents benchmark )
    end
  end
end