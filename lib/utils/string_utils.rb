# frozen_string_literal: true

module Utils
  module StringUtils
    refine String do
      def count_substring(substr)
        subarr = substr.chars
        each_char.each_cons(substr.size).count(subarr)
      end
    end
  end
end
