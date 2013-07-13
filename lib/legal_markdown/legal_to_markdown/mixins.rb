module LegalToMarkdown
  extend self

  module Mixins

    def run_mixins
      @orig_headers = @headers.clone if @writer == :jason
      clauses_mixins
      text_mixins
      clean_up_mixins
    end

    def clauses_mixins
      clauses_to_delete = []
      clauses_to_mixin = []

      @headers.each do | mixin, replacer |
        replacer = replacer.to_s.downcase
        clauses_to_delete << mixin if replacer == "false"
        clauses_to_mixin << mixin if replacer == "true"
      end

      clauses_to_delete.each { |m| @headers.delete(m) }
      clauses_to_mixin.each { |m| @headers.delete(m) }

      until clauses_to_delete.size == 0
        clauses_to_delete.each do | mixin |
          pattern = /(\[\{\{#{mixin}\}\}\s*?)(.*?\n*?)(\])/m
          sub_pattern = /\[\{\{(\S+?)\}\}\s*?/
          @content[pattern]
          get_it_all = $& || ""
          sub_clause = $2 || ""
          if sub_clause[sub_pattern] && clauses_to_delete.include?($1)
            next
          elsif sub_clause[sub_pattern]
            pattern = /\[\{\{#{mixin}\}\}\s*?.*?\n*?\].*?\n*?\]/m
            @content[pattern]; get_it_all = $& || ""
          end
          @content = @content.gsub( get_it_all, "" )
          clauses_to_delete.delete( mixin ) unless @content[pattern]
        end
      end

      until clauses_to_mixin.size == 0
        clauses_to_mixin.each do | mixin |
          pattern = /(\[\{\{#{mixin}\}\}\s*?)(.*?\n*?)(\])/m
          sub_pattern = /\[\{\{(\S+?)\}\}\s*?/
          @content[pattern]
          get_it_all = $& || ""
          sub_clause = $2 || ""
          next if sub_clause[sub_pattern] && clauses_to_mixin.include?($1)
          @content = @content.gsub( get_it_all, sub_clause.lstrip )
          clauses_to_mixin.delete( mixin ) unless @content[pattern]
        end
      end
    end

    def text_mixins
      @headers.each do | mixin, replacer |
        unless mixin =~ /level-\d/ or mixin =~ /no-reset/ or mixin =~ /no-indent/ or mixin =~ /level-style/
          replacer = replacer.to_s
          mixin_pattern = /(\{\{#{mixin}\}\})/
          @content = @content.gsub( $1, replacer ) if @content =~ mixin_pattern
          @headers.delete( mixin )
        end
      end
    end

    def clean_up_mixins
      @content.gsub!(/(\n\n+)/, "\n\n")
      @content.squeeze!(" ")
      @headers = nil if @headers.empty?
    end
  end
end