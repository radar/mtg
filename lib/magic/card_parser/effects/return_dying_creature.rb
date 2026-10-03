# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Return that card to the battlefield under its owner's control with a +1/+1 counter on it. It has flying
      # and is an Angel in addition to its other types." (Valkyrie's Call) -- in a creature-dies trigger, where
      # "that card" is the creature that died (`event.permanent.card`). The counter, keywords and type are
      # permanent (not until end of turn). Nothing happens if the card has left the graveyard by then.
      class ReturnDyingCreature < Data.define(:counter, :keywords, :type)
        include Effect

        LINE = /\AReturn that card to the battlefield under its owner's control(?: with an? (?<counter>\+1\/\+1) counter on it)?\.(?: It has (?<keywords>[\w ,]+?) and is an? (?<type>[A-Z][\w-]*) in addition to its other types\.)?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          keywords = m[:keywords] ? Rules::Keywords.phrase(m[:keywords]) : []
          return unless keywords
          return if m[:type] && !Types::Creatures.values.include?(m[:type])

          new(counter: m[:counter], keywords:, type: m[:type])
        end

        def resolve_call
          lines = ["returned = card.resolve!(controller: card.owner)", "if returned.is_a?(Permanent)"]
          lines << "  returned.add_counter(Counters[#{counter.inspect}])" if counter
          keywords.each { lines << "  returned.grant_keyword(Keywords.one(#{_1.inspect}), until_eot: false)" }
          lines << "  returned.add_types(T::Creatures[#{type.inspect}], until_eot: false)" if type
          lines << "end"
          "card = event.permanent.card\nif card.zone&.graveyard?\n#{lines.map { "  #{_1}" }.join("\n")}\nend"
        end
      end
    end
  end
end
