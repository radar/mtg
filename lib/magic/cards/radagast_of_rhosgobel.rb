module Magic
  module Cards
    RadagastOfRhosgobel = Creature("Radagast of Rhosgobel") do
      cost generic: 2, green: 2
      legendary_creature_type "Avatar Wizard"
      power 2
      toughness 5
    end

    class RadagastOfRhosgobel < Creature
      # "The first creature spell you cast each turn costs {2} less to cast and can be cast as though it had flash."
      module FirstCreatureSpell
        def first_creature_spell?(card, player)
          card.creature? && player == controller &&
            game.current_turn.spells_cast.none? { _1.player == player && _1.spell.creature? }
        end
      end

      class ReduceManaCost < Abilities::Static::ManaCostAdjustment
        include FirstCreatureSpell

        def initialize(source:)
          @source = source
          @adjustment = { generic: -2 }
        end

        def applies_to?(card) = first_creature_spell?(card, card.owner)
      end

      class FlashForFirstCreature < StaticAbility
        include FirstCreatureSpell

        def may_cast_with_flash?(card, player) = first_creature_spell?(card, player)
      end

      def static_abilities = [ReduceManaCost, FlashForFirstCreature]
    end
  end
end
