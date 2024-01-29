module Magic
  module Cards
    StormwingEntity = Creature("Stormwing Entity") do
      def cost
        Costs::Mana.new(generic: 3, blue: 2)
          .adjusted_by({ generic: -2, blue: -1 }, method(:instant_or_sorcery_cast_this_turn?))
      end
      cost generic: 3, blue: 2
      creature_type "Elemental"
      power 3
      toughness 3

      keywords :prowess

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(source: source, amount: 2))
      end

      private

      def instant_or_sorcery_cast_this_turn?
        current_turn.events.select { |event| event.is_a?(Events::SpellCast) }.any? do |event|
          event.player == controller && (event.spell.instant? || event.spell.sorcery?)
        end
      end
    end
  end
end
