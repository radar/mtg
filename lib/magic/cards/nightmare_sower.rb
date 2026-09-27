module Magic
  module Cards
    NightmareSower = Creature("Nightmare Sower") do
      cost generic: 3, black: 1
      creature_type("Faerie Assassin")
      keywords :flying, :lifelink
      power 2
      toughness 3
    end

    class NightmareSower < Creature
      class OpponentsTurnSpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !controllers_turn?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "-1/-1", target: target, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::SpellCast => OpponentsTurnSpellCastTrigger }
    end
  end
end
