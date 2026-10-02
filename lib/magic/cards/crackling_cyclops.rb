module Magic
  module Cards
    CracklingCyclops = Creature("Crackling Cyclops") do
      cost generic: 2, red: 1
      creature_type("Cyclops Wizard")
      power 0
      toughness 4
    end

    class CracklingCyclops < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.type?("Creature")
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 3, toughness: 0)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
