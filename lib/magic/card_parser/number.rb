# frozen_string_literal: true

module Magic
  class CardParser
    module Number
      WORDS = %w[zero one two three four five six seven eight nine ten].freeze

      # "3" => 3, "three" => 3, "a" => 1
      def self.parse(text)
        text = text.downcase
        return 1 if %w[a an].include?(text)
        return text.to_i if text.match?(/\A\d+\z/)

        WORDS.index(text) or raise UnsupportedCard, "unknown number: #{text}"
      end
    end
  end
end
