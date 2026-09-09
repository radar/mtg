module Magic
  module Cards
    JuriMasterOfTheRevue = Creature("Juri, Master of the Revue") do
      legendary_creature_type "Human Shaman"
      cost black: 1, red: 1
      power 1
      toughness 1
    end

    class JuriMasterOfTheRevue < Creature
      class SacrificeTrigger < TriggeredAbility
        def call
          actor.add_counter("+1/+1")
        end
      end

      class DeathTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor, amount: actor.power))
        end
      end

      class DamageChoice < Magic::Choice::Targeted
        attr_reader :amount

        def initialize(amount:, **args)
          @amount = amount
          super(**args)
        end

        def choices
          game.any_target
        end

        def resolve!(target:)
          actor.trigger_effect(:deal_damage, target: target, damage: amount)
        end
      end

      def event_handlers
        {
          Events::PermanentSacrificed => SacrificeTrigger,
          Events::CreatureDied => DeathTrigger,
        }
      end
    end
  end
end