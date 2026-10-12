module Magic
  module Cards
    CoriMountainStalwart = Creature("Cori Mountain Stalwart") do
      cost generic: 1, red: 1, white: 1
      creature_type("Human Monk")
      power 3
      toughness 3
    end

    class CoriMountainStalwart < Creature
      class FlurryTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && second_spell_this_turn?
        end

        def call
          game.opponents(controller).each { deal_damage(2, to: _1) }
          gain_life(2)
        end
      end

      def event_handlers = { Events::SpellCast => FlurryTrigger }
    end
  end
end
