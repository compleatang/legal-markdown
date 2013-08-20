#!/usr/bin/env ruby
require 'spec_helper'
include Fixtureshelper

describe "Legal Markdown Command Line Caller" do

  context "provides invalid commands" do
    describe "and no filenames" do
      if RUBY_VERSION == "2.0.0"
        let(:response) { "Sorry, I could not read the file to_markdown: no implicit conversion of Symbol into String." }
      else
        let(:response) { "Sorry, I could not read the file to_markdown: can't convert Symbol into String." }
      end
      let(:cmd) { `legal2md -m`.strip }
      it "should tell the user that there is no file to load." do
        expect( cmd ).to eql(response)
      end
    end

    describe "and invalid input file." do
      let(:response) { "Sorry, I could not read the file 12345.md: No such file or directory - 12345.md." }
      let(:cmd) { `legal2md 12345.md`.strip }
      it "should tell the user that it cannot load the file." do
        expect( cmd ).to eql(response)
      end
    end

    describe "and invalid input and output files." do
      let(:response) { "Sorry, I could not read the file 12345.lmd: No such file or directory - 12345.lmd." }
      let(:cmd) { `legal2md -m 12345.lmd 12345.md`.strip }
      it "should tell the user that it cannot load the file." do
        expect( cmd ).to eql(response)
      end
    end
  end

  context "provides valid commands" do
    let(:lmd_file) { cli_file }

    describe "and writes to stdout" do
      let(:cmd) { `cat #{lmd_file} | legal2md - -` }
      it "should write the output to the screen." do
        expect( cmd ).to eql( contents lmd_file )
      end
    end

    describe "and makes YAML frontmatter" do
      subject { `legal2md --headers #{lmd_file}` }
      it "should parse the file correctly." do
        expect( contents lmd_file ).to eql( contents cli_md_benchmark )
      end
    end

    describe "and parses files" do
      switches = [ '--to-markdown ', '--to-json ', '', '' ]     ## spec both auto fileext parser and explicit flags
      output = [ create_temp('md'), create_temp('json'), create_temp('md'), create_temp('json') ]
      switches.each_with_index do |switch, i|
        result = output[i]
        cmd = 'legal2md ' + [switch, cli_file.to_s, result.to_s].join(' ')
        `#{cmd}`
        type = File.extname(result).delete('.').upcase
        it "should parse all the #{type} file correctly." do
          expect( contents result ).to eql( contents cli_md_benchmark ) if type == 'MD'
          expect( contents result ).not_to eql( contents cli_json_benchmark || '' ) if type == 'JSON'
        end
      end
    end

    describe "and provides debug output" do
      let(:cmd) { `legal2md --debug #{cli_debug_subj} - > #{cli_debug_recipient}` }
      it "should parse the file and output the debug information." do
        expect( contents cli_debug_recipient ).to eql( contents cli_debug_benchmark )
      end
    end
  end
end