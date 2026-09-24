# frozen_string_literal: true

module Magic
  class CardParser
    # The "for each ..." in a variable amount -> a Ruby expression counting it, for
    # code with `controller` and `source` in scope (a static ability).
    #
    #   "Equipment you control"          -> controller.permanents.count { _1.type?("Equipment") }
    #   "other Elf you control"          -> (controller.permanents - [source]).count { _1.type?("Elf") }
    #   "card in your hand"              -> controller.hand.count
    #   "creature card in your graveyard" -> controller.graveyard.cards.count { _1.type?("Creature") }
    module Count
      TYPE = /[A-Za-z][\w-]*/
      PERMANENTS = /\A(?<other>other )?(?<type>#{TYPE}) you control\z/
      GRAVEYARD = /\A(?:(?<type>#{TYPE}) )?card in your graveyard\z/

      def self.parse(text)
        if (m = PERMANENTS.match(text))
          permanents = m[:other] ? "(controller.permanents - [source])" : "controller.permanents"
          "#{permanents}.count { _1.type?(#{type(m[:type]).inspect}) }"
        elsif text == "card in your hand"
          "controller.hand.count"
        elsif (m = GRAVEYARD.match(text))
          m[:type] ? "controller.graveyard.cards.count { _1.type?(#{type(m[:type]).inspect}) }" : "controller.graveyard.cards.count"
        end
      end

      # "creature" -> "Creature"; "Equipment", "Elf" stay as they are.
      def self.type(word) = word[0].upcase + word[1..]
    end
  end
end
