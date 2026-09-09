module Magic
  module Cards
    MayhemDevil = Creature("Mayhem Devil") do
      cost generic: 1, black: 1, red: 1
      creature_type "Devil"
      power 3
      toughness 3
    end

    class MayhemDevil < Creature
      class SacrificeTrigger < TriggeredAbility
        def call
          game.add_choice(DamageChoice.new(actor: actor))
        end
      end

      class DamageChoice < Magic::Choice::Targeted
        def choices
          game.any_target
        end

        def resolve!(target:)
          actor.trigger_effect(:deal_damage, target: target, damage: 1)
        end
      end

      def event_handlers
        { Events::PermanentSacrificed => SacrificeTrigger }
      end
    end
  end
end