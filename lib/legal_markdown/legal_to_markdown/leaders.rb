module LegalToMarkdown
  extend self

  module Leaders

    def run_leaders
      get_the_substitutions
      find_the_block
      if @block
        chew_on_the_block
        clean_up_leaders
      end
    end

    def get_the_substitutions
      # find the headers in the remaining YAML
      # parse out the headers into level-X and pre-X headers
      # then combine them into a coherent package
      # returns a hash with the keys as the l., ll. searches
      # and the values as the replacements in the form of
      # an array where the first value is a symbol and the
      # second value is the precursor
      #
      # @substitutions hash example
      # {"ll." || "l2."=>[:type8, "Article ", "(", "1", ")", :no_reset || nil, "  ", :preval || :pre || nil]}

      @substitutions = {}
      get_level_style
      get_the_indents
      get_the_levels
      get_the_resets
    end

    def find_the_block
      block_pattern = /(^```+\s*\n?)(.*?\n?)(^```+\s*\n?|\z)/m
      parts = @content.partition( block_pattern )
      if parts[1] != ""
        @block = $2.chomp
        @content = parts[0] + "{{block}}" + parts[2]
      else
        @block = nil
        @content = @content
      end
    end

    def chew_on_the_block
      # @substitutions hash example
      # {"ll."OR "l2."=>[:type8, "Article ", "(", "1", ")", :no_reset || nil, :no_indent || nil, :preval || :pre || nil],}
      @cross_references = {}
      arrayed_block = []
      @block.each_line do |line|
        next if line[/^\s+$/]
        line[/(^l+\.|^l\d\.)\s*(\|.*?\|)*\s*(.*)$/] ? arrayed_block << [$1, $3, $2] : arrayed_block.last[1] << ("\n" + line.rstrip)
      end
      @block = build_the_block_for_markdown arrayed_block if @writer == :markdown
      @block = build_the_block_for_jason arrayed_block if @writer == :jason
    end

    def clean_up_leaders
      @content.gsub!("{{block}}", @block ) if @writer == :markdown
      if @writer == :jason
        @content = @content.partition( /\{\{block\}\}/ )
        @content[1] = @block
      end
      @block = ""
    end

    private

    def get_level_style
      if @headers.has_key?("level-style")
        @headers["level-style"] =~ /l1/ ? @deep_leaders = true : @deep_leaders = false
        @headers.delete("level-style")
      else
        @deep_leaders = false
      end
    end

    def get_the_indents
      if @headers.has_key?("no-indent") && @headers["no-indent"]
        no_indent_array = @headers["no-indent"].split(", ")
        no_indent_array.include?("l." || "l1.") ? @offset = no_indent_array.size : @offset = no_indent_array.size + 1
      else
        @offset = 1
      end
      @headers.delete("no-indent")
    end

    def get_the_levels
      @headers.each do | header, value |
        if @deep_leaders
          search = "l" + header[-1] + "." if header =~ /level-\d/
        else
          search = "l" * header[-1].to_i + "." if header =~ /level-\d/
        end

        if header =~ /level-\d/
          @substitutions[search]= set_the_subs_arrays(value.to_s)
          @deep_leaders ? spaces = (search[1].to_i - @offset) : spaces = (search.size - @offset - 1)
          spaces < 0 ? spaces = 0 : spaces = spaces * 2
          @substitutions[search][6] = " " * spaces
          if value =~ /\s*preval\s*/
            @substitutions[search][1].gsub!(/preval\s*/, "")
            @substitutions[search][7] = :preval
          elsif value =~ /\s*pre\s*/
            @substitutions[search][1].gsub!(/pre\s*/, "")
            @substitutions[search][7] = :pre
          end
          @headers.delete(header)
        end
      end
    end

    def get_the_resets
      if @headers["no-reset"]
        no_subs_array = @headers["no-reset"].split(", ")
        no_subs_array.each{ |e| @substitutions[e][5] = :no_reset unless e == "l." || e == "l1."}
      end
      @headers.delete("no-reset")
    end

    def set_the_subs_arrays( value )
      # takes a core value from the hash pulled from the yaml
      # returns an array with a type symbol and a precursor string
      case
      when value =~ /([IVXLCDM]+)\.\z/            # type1 : {{ I. }}
        return[:type1, value.delete($1 + "."), "", $1, "."]
      when value =~ /\(([IVXLCDM]+)\)\z/       # type2 : {{ (I) }}
        return[:type2, value.delete("(" + $1 + ")"), "(", $1, ")"]
      when value =~ /([ivxlcdm]+)\.\z/         # type3 : {{ i. }}
        return[:type3, value.delete($1 + "."), "", $1, "."]
      when value =~ /\(([ivxlcdm]+)\)\z/       # type4 : {{ (i) }}
        return[:type4, value.delete("(" + $1 + ")"), "(", $1, ")"]
      when value =~ /([A-Z]+)\.\z/     # type5 : {{ A. }}
        return[:type5, value.delete($1 + "."), "", $1, "."]
      when value =~ /\(([A-Z]+)\)\z/   # type6 : {{ (A) }}
        return[:type6, value.delete("(" + $1 + ")"), "(", $1, ")"]
      when value =~ /([a-z]+)\.\z/     # type7 : {{ a. }}
        return[:type7, value.delete($1 + "."), "", $1, "."]
      when value =~ /\(([a-z]+)\)\z/   # type8 : {{ (a) }}
        return[:type8, value.delete("(" + $1 + ")"), "(", $1, ")"]
      when value =~ /\((\d+)\)\z/      # type9 : {{ (1) }}
        return[:type9, value.delete("(" + $1 + ")"), "(", $1, ")"]
      else value =~ /(\d+)\.\z/         # type0 : {{ 1. }} ... also default
        return[:type0, value.delete($1 + "."), "", $1, "."]
      end
    end

    def romans_takedown( array_to_sub )
      if array_to_sub[0] == :type1 || array_to_sub[0] == :type2
        @r_u = true
      elsif array_to_sub[0] == :type3 || array_to_sub[0] == :type4
        @r_l = true
      end
      if @r_l || @r_u
        array_to_sub[3] = RomanNumerals.to_decimal_string(array_to_sub[3])
      end
      return array_to_sub
    end

    def romans_setup( array_to_sub )
      if @r_l || @r_u
        array_to_sub[3] = RomanNumerals.to_roman_upper(array_to_sub[3]) if @r_u
        array_to_sub[3] = RomanNumerals.to_roman_lower(array_to_sub[3]) if @r_l
      end
      @r_l = false; @r_u = false
      return array_to_sub
    end

    def increment_the_branch( array_to_sub, selector, next_selector )
      if selector > next_selector                                         #going up the tree and reset
        selectors_to_reset = @substitutions.inject([]){ |m,(k,v)| m << k if k > next_selector; m }
        selectors_to_reset.each do | this_selector |
          substitutor = @substitutions[this_selector]
          substitutor = romans_takedown( substitutor )
          substitutor[3].next! if this_selector == selector
          if substitutor[0] == :type5 || substitutor[0] == :type6
            substitutor[3] = "A" unless substitutor[5] == :no_reset
          elsif substitutor[0] == :type7 || substitutor[0] == :type8
            substitutor[3] = "a" unless substitutor[5] == :no_reset
          else
            substitutor[3] = "1" unless substitutor[5] == :no_reset
          end
          substitutor = romans_setup( substitutor )
          @substitutions[this_selector]= substitutor
        end
        array_to_sub = @substitutions[selector]
      else                                                                #not going up tree
        array_to_sub = romans_takedown( array_to_sub )
        array_to_sub[3].next!
        array_to_sub = romans_setup( array_to_sub )
      end

      return array_to_sub
    end

    def get_selector_above( selector )
      if @deep_leaders
        selector_above = "l" + (selector[1].to_i-1).to_s + "."
        selector_above = "l1." if selector_above == "l0."
      else
        selector_above = selector[1..-1]
        selector_above = "l." if selector_above == "."
      end
      return selector_above
    end

    def find_parent_reference( selector_above )
      leading_prov = @substitutions[selector_above].clone
      leading_prov = romans_takedown( leading_prov )
      if leading_prov[0] == ( :type5 || :type6 || :type7 || :type8 )
        leading_prov[3] = leading_prov[3][0..-2] + (leading_prov[3][-1].ord-1).chr
      else
        leading_prov[3] = (leading_prov[3].to_i-1).to_s
      end
      leading_prov = romans_setup( leading_prov )
      return leading_prov
    end

    def preval_substitution( array_to_sub, selector )
      array_to_sub.pop unless array_to_sub.last == :preval
      selector_above = get_selector_above( selector )
      leading_prov = find_parent_reference( selector_above )[3]
      trailing_prov = array_to_sub[3].clone
      trailing_prov = "0" + trailing_prov if trailing_prov.size == 1
      array_to_sub << array_to_sub[2] + leading_prov.to_s + trailing_prov.to_s + array_to_sub[4]
      array_to_sub.last.gsub!($1, "(") if array_to_sub.last[/(\.\()/]
      return array_to_sub
    end

    def pre_substitution( array_to_sub, selector )
      array_to_sub.pop unless array_to_sub.last == :pre
      selector_above = get_selector_above( selector )
      leading_prov = @substitutions[selector_above][8] || find_parent_reference( selector_above )[2..4].join
      trailing_prov = array_to_sub[2..4].join
      array_to_sub << leading_prov + trailing_prov
      array_to_sub.last.gsub!($1, "(") if array_to_sub.last[/(\.\()/]
      return array_to_sub
    end

    def log_the_line( block, sub_it, reference, arrayed_line )
      arrayed_line[1].gsub!("\n", "\n\n" + sub_it[6]) if arrayed_line[1] =~ /\n/
      block << sub_it[6] + sub_it[1] + reference + " " + arrayed_line[1] + "\n\n"
    end

    def log_the_key( block, sub_it, reference, selector, arrayed_line, arrayed_block )
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
      #       "provision_text" => "text" #gaurd italics
      #       "citation" => "citation" #todo
      #       "substitution" => sub_it array #for json=>lmd reversion
      #   "annotation:SHA32"
      #     "id" => "annotation:SHA32"
      #     "type" => "citation"
      #     "data"
      #       "pos" => [start_column, stop_column]
      #       "citation_type" => "internal" | "external"
      #       "cite_of" => #todo
      #       "node" => "id"  ... if internal
      #       "substitution" => for json=>reversion
      #   "content" => "nodes" => ["provision:SHA32", ...]
      # but this method is only chewing on the middle bits where it says provision || annotation.
      # the json_builder module will handle the rest.
      provision = { "id" => "provision:" + SecureRandom.hex, "type" => "provision" }
      provision["data"]= {
        "level" => @deep_leaders ? selector[-1] : (selector.length - 1).to_s,
        "provision_reference" => sub_it[1] + reference,
        "provision_text" => arrayed_line[1].count("*") % 2 != 0 ? arrayed_line[1].sub("*", "") : arrayed_line[1],
        "citation" => "",
        "substitution" => sub_it
      }
      return provision
    end

    def build_an_annotation( start, stop, cite, parent, substitution )
      annotation = { "id" => "annotation:" + SecureRandom.hex, "type" => "citation"}
      annotation["data"]= {
        "pos" => [start, stop],
        "citation_type" => "internal",
        "cite_of" => cite,
        "node" => parent,
        "substitution" => substitution
      }
      return annotation
    end

    def block_builder( arrayed_line )
      selector = arrayed_line.first
      sub_it = @substitutions[selector]
      if sub_it[7] == :preval
        sub_it = preval_substitution( sub_it, selector )
        reference = sub_it.last
      elsif sub_it[7] == :pre
        sub_it = pre_substitution( sub_it, selector )
        reference = sub_it.last
      else
        reference = sub_it[2..4].join
      end
      @cross_references[arrayed_line[2]]= sub_it[1].gsub(/\A\* *|\#+ */, "") + reference.chomp(".") if arrayed_line[2]
      return [sub_it, reference, selector, arrayed_line]
    end

    def block_incrementer( arrayed_line, arrayed_block, selector, sub_it )
      unless arrayed_line == arrayed_block.last
        next_selector = arrayed_block[arrayed_block.index(arrayed_line)+1].first
        @substitutions[selector]= increment_the_branch(sub_it, selector, next_selector)
      end
    end

    def build_the_block_for_markdown( arrayed_block )
      new_block = arrayed_block.inject("") do |block, arrayed_line|
        (sub_it, reference, selector, arrayed_line) = block_builder arrayed_line
        log_the_line block, sub_it, reference, arrayed_line
        block_incrementer arrayed_line, arrayed_block, selector, sub_it
        block
      end
      @cross_references.each_key{|k| new_block.gsub!(k, @cross_references[k]) }
      new_block
    end

    def build_the_block_for_jason( arrayed_block )
      require 'securerandom'
      annotations_hash = {}
      provisions_hash = arrayed_block.inject({}) do |block, arrayed_line|
        (sub_it, reference, selector, arrayed_line) = block_builder arrayed_line
        provision = log_the_key block, sub_it, reference, selector, arrayed_line, arrayed_block
        block_incrementer arrayed_line, arrayed_block, selector, sub_it
        block[provision["id"]]= provision
        block
      end
      provisions_hash.each_value do |h|
        if h["data"]["provision_text"][/(\|.*?\|)/]
          ref = @cross_references[$1]
          h["data"]["provision_text"].gsub!($1, ref)
          start = h["data"]["provision_text"].index(ref) + 1
          stop = start + ref.length
          cite = provisions_hash.each_value{|h| return h["id"] if h["data"]["provision_reference"] == ref}
          parent = h["id"]
          substitution = $1
          annotation = build_an_annotation start, stop, cite, parent, substitution
          annotations_hash[annotation["id"]]= annotation
        else
          next
        end
      end
      provisions_hash.merge(annotations_hash)
    end
  end
end