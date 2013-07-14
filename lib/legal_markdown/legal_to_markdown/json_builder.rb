module LegalToMarkdown
  extend self

  module JasonBuilder
    require 'securerandom'
    # this method will build a hash which we will use to build the structured JSON.
    # roughly the hash / json will break down like this ....
    # "id"
    # "nodes"
    #   "document"
    #     "title" => ""
    #     "abstract" => ""
    #     "views" => ["content"]
    #   "provision:SHA32"
    #     "id" => "provision:SHA32"
    #     "type" => "provision"
    #     "data"
    #       "level" => "level"
    #       "provision_reference" => "assembled leader"
    #       "provision_text" => "line - leader" #gaurd italics
    #       "citation" => "citation"
    #   "annotation:SHA32"
    #     "id" => "annotation:SHA32"
    #     "type" => "citation"
    #     "data"
    #       "pos" => [start_column, stop_column]
    #       "citation_type" => "internal" | "external"
    #       "cite_of" => #todo
    #   "content" => "nodes" => ["provision:SHA32", ...]

    def build_jason
      if @content.is_a?(Array)
        @content[0] = build_header_and_text_hashs @content[0] unless @content[0].empty?
        @content[2] = build_header_and_text_hashs @content[2] unless @content[2].empty?
        content_hash = {}
        content_hash = content_hash.merge(@content[0]) unless @content[0] || @content[0].empty?
        content_hash = content_hash.merge(@content[1])
        content_hash = content_hash.merge(@content[2]) unless @content[2] || @content[2].empty?
        @content = content_hash
      else
        @content = build_header_and_text_hashs @content
      end
      back_hash = build_back_portion @content
      document_hash = build_front_portion.merge( @content ).merge( back_hash ); back_hash = {}
      @content = {
        "id" => sha,
        "nodes" => document_hash
      }
    end

    def build_front_portion
      document_hash = { "document" => { "title" => "", "abstract" => "", "views" => ["content"] }}
    end

    def build_header_and_text_hashs( text_block )
      text_block = text_block.split("\n").reject{|l| l == ""}
      text_block.inject({}) do |hash, line|
        h2 = {}
        if line[/^(\#+\s+)/]
          h2["id"]= "heading:" + sha
          h2["type"]= "heading"
          h2["data"]= { "content" => line.delete($1) }
        elsif line[/^\S/]
          h2["id"]= "text:" + sha
          h2["type"]= "text"
          h2["data"]= { "content" => line }
        end
        hash.merge( { h2["id"] => h2 } )
      end
    end

    def build_back_portion( content_hash )
      back_hash = content_hash.each_value.collect{|h| h["id"]}
      back_hash = { "content" => { "nodes" => back_hash } }
    end

    def sha
      return SecureRandom.hex
    end
  end
end