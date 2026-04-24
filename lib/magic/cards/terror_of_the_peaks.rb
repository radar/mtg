module Magic
  module Cards
    TerrorOfThePeaks = Creature("Terror of the Peaks") do
      cost generic: 3, red: 2
      creature_type "Dragon"
      keywords :flying
      power 5
      toughness 4
    end

    class TerrorOfThePeaks < Creature
      class WardTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:lose_life, target: event.player, life: 3)
        end
      end

      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          game.choices.add(TerrorOfThePeaks::DamageChoice.new(
            actor: actor,
            power: event.permanent.power
          ))
        end
      end

      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, power:)
          super(actor: actor)
          @power = power
        end

        def choices
          game.any_target
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: @power, target: target)
        end
      end

      def event_handlers
        {
          Events::SpellCast => WardTrigger,
          Events::EnteredTheBattlefield => CreatureEnteredTrigger
        }
      end
    end
  end
end
