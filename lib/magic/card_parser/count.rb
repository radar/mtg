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
    #   "the number of colors among permanents you control" -> controller.colors_among_permanents
    module Count
      TYPE = /[A-Za-z][\w-]*/
      PERMANENTS = /\A(?<other>other )?(?<type>#{TYPE}) you control\z/
      # "instant and sorcery cards" / "instant and/or sorcery cards": either of the two types.
      INSTANT_OR_SORCERY = %r{instant (?:and/or|or|and) sorcery}
      GRAVEYARD = /\A(?:(?<type>#{INSTANT_OR_SORCERY}|#{TYPE}) )?cards? in your graveyard\z/

      # Card types with a named collection on Player (and so on its permanents).
      YOUR_PERMANENTS = { "creature" => "creatures", "land" => "lands", "artifact" => "artifacts", "enchantment" => "enchantments",
                          "planeswalker" => "planeswalkers", "equipment" => "equipment" }.freeze
      # ... and on a zone's cards.
      GRAVEYARD_CARDS = { "creature" => "creatures", "land" => "lands", "enchantment" => "enchantments" }.freeze

      # Vivid: "the number of colors among permanents you control".
      COLORS_AMONG = /\A(?:the number of colors|each color|color) among permanents you control\z/

      # "the greatest power among other creatures you control" (Prime Speaker Zegana), and "its power".
      GREATEST_POWER = /\Athe greatest power among (?<other>other )?creatures you control\z/
      ITS_POWER = /\A(?:its|~'s) power\z/

      # "the number of counters on ~" (Warden of the Grove).
      COUNTERS_ON_THIS = /\A(?:the number of )?counters on ~\z/

      # "different mana value among nonland permanents you control" (Lunar Insight).
      DIFFERENT_MANA_VALUES = /\Adifferent mana values? among nonland permanents you control\z/
      # "attacking creature": the creatures declared as attackers (a trigger on `Events::FinalAttackersDeclared`).
      ATTACKING_CREATURES = /\Aattacking creatures?\z/

      # "other creatures you control named ~" (Hare Apparent): creatures sharing the object's name.
      OTHER_NAMED_THIS = /\A(?:the number of )?other creatures you control named ~\z/

      # "the amount of life you gained this turn" (Midnight Snack), from the turn's event log.
      LIFE_GAINED_THIS_TURN = /\A(?:the )?amount of life you gained this turn\z/

      # "the mana value of that spell" (a spell-cast trigger, where `event.spell` is the spell).
      MANA_VALUE_OF_SPELL = /\Athe mana value of that spell\z/

      def self.parse(text, this: "source")
        return "event.spell.mana_value" if MANA_VALUE_OF_SPELL.match?(text)
        return "game.current_turn.events.select { |e| e.is_a?(Events::LifeGain) && e.player == controller }.sum(&:life)" if LIFE_GAINED_THIS_TURN.match?(text)
        return "controller.creatures.count { _1 != #{this} && _1.name == #{this}.name }" if OTHER_NAMED_THIS.match?(text)
        return "controller.colors_among_permanents" if COLORS_AMONG.match?(text)
        return "controller.permanents.reject(&:land?).map(&:mana_value).uniq.count" if DIFFERENT_MANA_VALUES.match?(text)
        return "event.attacks.count { _1.attacker.controller == controller }" if ATTACKING_CREATURES.match?(text)

        return "(controller.creatures#{".except(#{this})" if $~[:other]}.map(&:power).max || 0)" if GREATEST_POWER.match(text)
        return "#{this}.power" if ITS_POWER.match?(text)

        text = text.delete_prefix("the number of ")
        if (m = PERMANENTS.match(text))
          permanents = collection("controller", YOUR_PERMANENTS, Condition.singular(m[:type]), all: "controller.permanents")
          "#{permanents}#{".except(#{this})" if m[:other]}.count"
        elsif text.match?(COUNTERS_ON_THIS)
          "#{this}.counters.count"
        elsif text == "card in your hand"
          "controller.hand.count"
        elsif (m = GRAVEYARD.match(text))
          "#{graveyard_cards(m[:type])}.count"
        end
      end

      # The Ruby for the cards of `type` (nil: any) in your graveyard.
      def self.graveyard_cards(type)
        return "controller.graveyard.cards" unless type
        return 'controller.graveyard.cards.by_any_type("Instant", "Sorcery")' if INSTANT_OR_SORCERY.match?(type)

        collection("controller.graveyard", GRAVEYARD_CARDS, type)
      end

      # controller.creatures, or controller.permanents.by_type("Elf") for other types.
      def self.collection(owner, named, type, all: owner)
        method = named[type.downcase] and return "#{owner}.#{method}"

        "#{all}.by_type(#{(type[0].upcase + type[1..]).inspect})"
      end
    end
  end
end
