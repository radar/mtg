# frozen_string_literal: true

module Magic
  class CardParser
    # The "as long as ..." of a static ability -> a Ruby expression for its
    # `conditions` block (controller, source and game are in scope there).
    #
    #   "you control an artifact"            -> controller.artifacts.any?
    #   "you control another Elf"            -> controller.permanents.by_type("Elf").except(source).any?
    #   "you control three or more creatures" -> controller.creatures.count >= 3
    #   "it's your turn"                     -> game.current_turn.active_player == controller
    #   "you have no cards in hand"          -> controller.hand.empty?
    module Condition
      ONE = /\Ayou control (?:an?|(?<another>another)) (?<type>#{Count::TYPE})\z/
      MANY = /\Ayou control (?<amount>\d+|\w+) or more (?<types>#{Count::TYPE})\z/

      def self.parse(text)
        if (m = ONE.match(text))
          "#{permanents(m[:type])}#{'.except(source)' if m[:another]}.any?"
        elsif (m = MANY.match(text))
          "#{permanents(singular(m[:types]))}.count >= #{Number.parse(m[:amount])}"
        elsif text.match?(/\Ait's your turn\z/)
          "game.current_turn.active_player == controller"
        elsif text.match?(/\Ayou have no cards in hand\z/)
          "controller.hand.empty?"
        end
      end

      def self.permanents(type) = Count.collection("controller", Count::YOUR_PERMANENTS, type, all: "controller.permanents")

      # "creatures" -> "creature", "Elves" -> "Elf", "Equipment" stays.
      def self.singular(word)
        return word if Count::YOUR_PERMANENTS.key?(word.downcase)

        plural = word.downcase.delete_suffix("s")
        return plural if Count::YOUR_PERMANENTS.key?(plural)

        CreatureType.singular(word)
      end
    end
  end
end
