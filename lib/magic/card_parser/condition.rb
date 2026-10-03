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
    #   "you have 30 or more life"           -> controller.life >= 30
    #   "~ is tapped"                        -> source.tapped?
    module Condition
      ONE = /\Ayou control (?:an?|(?<another>another)) (?<type>#{Count::TYPE})\z/
      MANY = /\Ayou control (?<amount>\d+|\w+) or more (?<types>#{Count::TYPE})\z/
      NONE = /\Ayou control no (?<other>other )?(?<types>#{Count::TYPE})\z/
      LIFE = /\A(?<who>you have|an opponent has) (?<amount>\d+|\w+) or (?<cmp>more|less) life\z/
      GRAVEYARD = /\Athere are (?<amount>\d+|\w+) or more (?:(?<type>creature|land|enchantment) )?cards in your graveyard\z/
      COUNTERS = %r{\A~ has (?<amount>\d+|\w+) or more (?<counter>[\w+/-]+) counters on it\z}
      SELF = {
        "~ is tapped" => "source.tapped?",
        "~ is untapped" => "source.untapped?",
        # Raid: the log has a FinalAttackersDeclared with attacks for the controller's turn.
        "you attacked this turn" => "game.current_turn.events.any? { |e| e.is_a?(Events::FinalAttackersDeclared) && e.active_player == controller && e.attacks.any? }",
        "an opponent lost life this turn" => "game.current_turn.events.any? { |e| e.is_a?(Events::LifeLoss) && e.player != controller }",
        "~ is equipped" => 'source.attachments.any? { _1.type?("Equipment") }',
        "~ is enchanted" => 'source.attachments.any? { _1.type?("Aura") }'
      }.freeze

      def self.parse(text)
        if (m = ONE.match(text))
          "#{permanents(m[:type])}#{'.except(source)' if m[:another]}.any?"
        elsif (m = MANY.match(text))
          "#{permanents(singular(m[:types]))}.count >= #{Number.parse(m[:amount])}"
        elsif (m = NONE.match(text))
          "#{permanents(singular(m[:types]))}#{'.except(source)' if m[:other]}.none?"
        elsif (m = LIFE.match(text))
          life(m)
        elsif (m = GRAVEYARD.match(text))
          cards = m[:type] ? Count.collection("controller.graveyard", Count::GRAVEYARD_CARDS, m[:type]) : "controller.graveyard.cards"
          "#{cards}.count >= #{Number.parse(m[:amount])}"
        elsif (m = COUNTERS.match(text))
          counters(m)
        elsif (m = /\Ait's (?<not>not )?your turn\z/.match(text))
          "game.current_turn.active_player #{m[:not] ? '!=' : '=='} controller"
        elsif text.match?(/\Ayou have no cards in hand\z/)
          "controller.hand.empty?"
        else
          SELF[text]
        end
      end

      # nil for a counter type Magic::Counters doesn't know.
      def self.counters(match)
        counter = Magic::Counters[match[:counter].downcase].name.split("::").last
        "source.counters.of_type(Counters::#{counter}).count >= #{Number.parse(match[:amount])}"
      rescue RuntimeError => e
        raise unless e.message.start_with?("Unknown counter type")
      end

      def self.life(match)
        comparison = "#{match[:cmp] == 'more' ? '>=' : '<='} #{Number.parse(match[:amount])}"
        match[:who] == "you have" ? "controller.life #{comparison}" : "game.opponents(controller).any? { _1.life #{comparison} }"
      end

      def self.permanents(type) = Count.collection("controller", Count::YOUR_PERMANENTS, type, all: "controller.permanents")

      # "creatures" -> "creature", "Elves" -> "Elf", "Equipment" stays.
      def self.singular(word)
        return word if Count::YOUR_PERMANENTS.key?(word.downcase)

        plural = word.downcase.delete_suffix("s")
        return plural if Count::YOUR_PERMANENTS.key?(plural)
        return Magic::Types::Lands::Gate if plural.capitalize == Magic::Types::Lands::Gate

        CreatureType.singular(word)
      end
    end
  end
end
