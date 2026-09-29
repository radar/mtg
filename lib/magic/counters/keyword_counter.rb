module Magic
  module Counters
    # A keyword counter ("a flying counter"): the permanent has the keyword for as long as it has
    # the counter, even after losing all abilities (the counter is applied after that effect).
    # Subclasses define `.keyword`.
    class KeywordCounter
      def self.keyword = raise(NotImplementedError, "#{name} must define .keyword")

      def keyword = self.class.keyword
      def power_modification = 0
      def toughness_modification = 0
    end
  end
end
