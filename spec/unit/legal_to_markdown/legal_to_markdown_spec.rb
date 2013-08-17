#!/usr/bin/env ruby
require 'spec_helper'
include Fixtureshelper

describe "Legal Markdown to" do

  describe "Markdown" do
    lmd_files.each do | lmd_file |
      lmd = File.basename(lmd_file)
      it "should correctly parse #{lmd}" do
        benchmark = benchmark_file lmd_file, 'md'
        result = create_temp 'md'
        LegalMarkdown.parse( :to_markdown, lmd_file,  result )
        expect( contents result ).to eql( contents benchmark )
      end
    end
  end

  describe "JSON." do
    lmd_files.each do |lmd_file|
      lmd = File.basename(lmd_file)
      it "should correctly parse #{lmd}" do
        benchmark = benchmark_file lmd_file, 'json'
        result = create_temp 'json'
        LegalMarkdown.parse( :to_json, lmd_file,  result )
        expect( contents benchmark ).not_to eql( contents result )
        expect( (contents benchmark)['nodes'].count ).to eql( (contents result)['nodes'].count )
        expect( (contents benchmark)['nodes']["document"] ).to eql( (contents result)['nodes']["document"] )
        expect( (contents benchmark)['nodes']["content"]["nodes"]).not_to eql( (contents result)['nodes']["content"]["nodes"] )
        expect( the_content benchmark ).to eql( the_content result )
      end
    end
  end
end
