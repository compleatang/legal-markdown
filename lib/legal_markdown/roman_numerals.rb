# Extracted from Roman Numerals gem

# Copyright (c) 2011 Andrew Vos

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


module RomanNumerals
  @base_digits = {
    1    => 'I',
    4    => 'IV',
    5    => 'V',
    9    => 'IX',
    10   => 'X',
    40   => 'XL',
    50   => 'L',
    90   => 'XC',
    100  => 'C',
    400  => 'CD',
    500  => 'D',
    900  => 'CM',
    1000 => 'M'
  }

  def self.to_roman_upper(value)
    value = value.to_i
    result = ''
    @base_digits.keys.reverse.each do |decimal|
      while value >= decimal
        value -= decimal
        result += @base_digits[decimal]
      end
    end
    result
  end

  def self.to_roman_lower(value)
    self.to_roman_upper(value).downcase
  end

  def self.to_decimal_string(value)
    value.upcase!
    result = 0
    @base_digits.values.reverse.each do |roman|
      while value.start_with? roman
        value = value.slice(roman.length, value.length)
        result += @base_digits.key roman
      end
    end
    result.to_s
  end
end
