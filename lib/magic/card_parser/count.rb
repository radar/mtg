# frozen_string_literal: true

module Magic
  class CardParser
    # The "for each ..." in a variable amount -> a Ruby expression counting it, for
    # code with `controller` in scope. `this` is Ruby for the object itself ("other"
    # leaves it out): `source` in a static ability, Effect::THIS in an effect.
    #
    #   "Equipment you control"           -> controller.equipment.count
    #   "other Elf you control"           -> controller.permanents.by_type("Elf").except(source).count
    #   "card in your hand"               -> controller.hand.count
    #   "creature card in your graveyard" -> controller.graveyard.creatures.count
    module Count
      TYPE = /[A-Za-z][\w-]*/
      PERMANENTS = /\A(?<other>other )?(?<type>#{TYPE}) you control\z/
      GRAVEYARD = /\A(?:(?<type>#{TYPE}) )?card in your graveyard\z/

      # Card types with a named collection on Player (and so on its permanents).
      YOUR_PERMANENTS = { "creature" => "creatures", "land" => "lands", "artifact" => "artifacts", "enchantment" => "enchantments",
                          "planeswalker" => "planeswalkers", "equipment" => "equipment" }.freeze
      # ... and on a zone's cards.
      GRAVEYARD_CARDS = { "creature" => "creatures", "land" => "lands", "enchantment" => "enchantments" }.freeze

      def self.parse(text, this: "source")
        if (m = PERMANENTS.match(text))
          permanents = collection("controller", YOUR_PERMANENTS, m[:type], all: "controller.permanents")
          "#{permanents}#{".except(#{this})" if m[:other]}.count"
        elsif text == "card in your hand"
          "controller.hand.count"
        elsif (m = GRAVEYARD.match(text))
          m[:type] ? "#{collection('controller.graveyard', GRAVEYARD_CARDS, m[:type])}.count" : "controller.graveyard.cards.count"
        end
      end

      # controller.creatures, or controller.permanents.by_type("Elf") for other types.
      def self.collection(owner, named, type, all: owner)
        method = named[type.downcase] and return "#{owner}.#{method}"

        "#{all}.by_type(#{(type[0].upcase + type[1..]).inspect})"
      end
    end
  end
end
