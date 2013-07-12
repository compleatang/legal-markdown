module LegalToMarkdown
  extend self

  private

  # ----------------------
  # |      Step 4        |
  # ----------------------
  # Headers

  def headers_on( headers, content )

    def set_the_subs_arrays( value )
      # takes a core value from the hash pulled from the yaml
      # returns an array with a type symbol and a precursor string
      if value =~ /([IVXLCDM]+)\.\z/            # type1 : {{ I. }}
        return[:type1, value.delete($1 + "."), "", $1, "."]
      elsif value =~ /\(([IVXLCDM]+)\)\z/       # type2 : {{ (I) }}
        return[:type2, value.delete("(" + $1 + ")"), "(", $1, ")"]
      elsif value =~ /([ivxlcdm]+)\.\z/         # type3 : {{ i. }}
        return[:type3, value.delete($1 + "."), "", $1, "."]
      elsif value =~ /\(([ivxlcdm]+)\)\z/       # type4 : {{ (i) }}
        return[:type4, value.delete("(" + $1 + ")"), "(", $1, ")"]
      elsif value =~ /([A-Z]+)\.\z/     # type5 : {{ A. }}
        return[:type5, value.delete($1 + "."), "", $1, "."]
      elsif value =~ /\(([A-Z]+)\)\z/   # type6 : {{ (A) }}
        return[:type6, value.delete("(" + $1 + ")"), "(", $1, ")"]
      elsif value =~ /([a-z]+)\.\z/     # type7 : {{ a. }}
        return[:type7, value.delete($1 + "."), "", $1, "."]
      elsif value =~ /\(([a-z]+)\)\z/   # type8 : {{ (a) }}
        return[:type8, value.delete("(" + $1 + ")"), "(", $1, ")"]
      elsif value =~ /\((\d+)\)\z/      # type9 : {{ (1) }}
        return[:type9, value.delete("(" + $1 + ")"), "(", $1, ")"]
      else value =~ /(\d+)\.\z/         # type0 : {{ 1. }} ... also default
        return[:type0, value.delete($1 + "."), "", $1, "."]
      end
    end

    def get_the_substitutions( headers )
      # find the headers in the remaining YAML
      # parse out the headers into level-X and pre-X headers
      # then combine them into a coherent package
      # returns a hash with the keys as the l., ll. searches
      # and the values as the replacements in the form of
      # an array where the first value is a symbol and the
      # second value is the precursor

      # @substitutions hash example
      # {"ll." || "l2."=>[:type8, "Article ", "(", "1", ")", :no_reset || nil, "  ", :preval || :pre || nil]}

      @substitutions = {}

      if headers.has_key?("level-style")
        headers["level-style"] =~ /l1/ ? @deep_leaders = true : @deep_leaders = false
      else
        @deep_leaders = false
      end

      if headers.has_key?("no-indent") && headers["no-indent"]
        no_indent_array = headers["no-indent"].split(", ")
        no_indent_array.include?("l." || "l1.") ? @offset = no_indent_array.size : @offset = no_indent_array.size + 1
      else
        @offset = 1
      end

      headers.each do | header, value |
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
        end
      end

      if headers["no-reset"]
        no_subs_array = headers["no-reset"].split(", ")
        no_subs_array.each{ |e| @substitutions[e][5] = :no_reset unless e == "l." || e == "l1."}
      end

      return @substitutions
    end

    def find_the_block( content )
      block_pattern = /(^```+\s*\n?)(.*?\n?)(^```+\s*\n?)/m
      parts = content.partition( block_pattern )
      if parts[1] != ""
        block = $2.chomp
        content = parts[0] + "{{block}}" + parts[2]
      else
        block = ""
        content = content
      end
      return [ block, content ]
    end

    def chew_on_the_block( old_block )
      # takes a hash of substitutions to make from the #get_the_substitutions method
      # and a block of text returned from the #find_the_block method
      # iterates over the block to make the appropriate substitutions
      # returns a block of text

      # method will take the old_block and iterate through the lines.
      # First it will find the leading indicator. Then it will
      # find the appropriate substitution from the @substitutions
      # hash. After that it will rebuild the leading matter from the
      # sub hash. It will drop markers if it is going down the tree.
      # It will reset the branches if it is going up the tree.
      # sub_it is an array w/ type[0] & lead_string[1] & id's[2..4]

      # @substitutions hash example
      # {"ll."OR "l2."=>[:type8, "Article ", "(", "1", ")", :no_reset || nil, :no_indent || nil, :preval || :pre || nil],}

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
        if leading_prov[0] == :type5 || leading_prov[0] == :type6
          leading_prov[3] = leading_prov[3][0..-2] + (leading_prov[3][-1].ord-1).chr
        elsif leading_prov[0] == :type7 || leading_prov[0] == :type8
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

      cross_references = {}
      arrayed_block = []
      old_block.each_line do |line|
        next if line[/^\s*\n/]
        line[/(^l+\.|^l\d\.)\s*(\|.*?\|)*\s*(.*)$/] ? arrayed_block << [$1, $3, $2] : arrayed_block.last[1] << ("\n" + line.rstrip)
      end
      old_block = ""                        # for large files

      new_block = arrayed_block.inject("") do |block, arrayed_line|

        selector = arrayed_line[0]
        next_selector = ( arrayed_block[arrayed_block.index(arrayed_line)+1] || arrayed_block.last ).first
        sub_it = @substitutions[selector]

        if arrayed_line[1] =~ /\n/
          arrayed_line[1].gsub!("\n", "\n\n" + sub_it[6])
        end

        if sub_it[7] == :preval
          sub_it = preval_substitution(sub_it, selector)
          reference = sub_it.last
        elsif sub_it[7] == :pre
          sub_it = pre_substitution(sub_it, selector)
          reference = sub_it.last
        else
          reference = sub_it[2..4].join
        end

        block << sub_it[6] + sub_it[1] + reference + " " + arrayed_line[1] + "\n\n"
        if arrayed_line[2]
          cross_references[arrayed_line[2]]= sub_it[1] + reference
          cross_references[arrayed_line[2]].gsub!(/\A\*|\#+ |\.\z/, "")                    #guard against formatting of headers into txt
        end
        @substitutions[selector]= increment_the_branch(sub_it, selector, next_selector)

        block
      end

      cross_references.each_key{|k| new_block.gsub!(k, cross_references[k]) }
      return new_block
    end

    headers = get_the_substitutions( headers )
    block_found = find_the_block( content )
    block = block_found[0]
    not_the_block = block_found[1]
    block_found = ""                                                        # for long documents

    if block == ""
      block_redux = ""
    elsif headers == {}
      block_redux = block
    else
      block_redux = chew_on_the_block( block )
    end
    headed = not_the_block.gsub("{{block}}", block_redux )
  end
end