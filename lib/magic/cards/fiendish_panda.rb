module Magic
  module Cards
    FiendishPanda = Creature("Fiendish Panda") do
      cost generic: 2, white: 1, black: 1
      creature_type("Bear Demon")
      power 3
      toughness 2
    end

    class FiendishPanda < Creature
      class DiesTrigger < TriggeredAbility::Death
        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.type?("Creature") && !_1.type?("Bear") && _1.mana_value <= actor.power && _1 != actor.card }
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: target.owner)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]

      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = super.merge({ Events::LifeGain => LifeGainTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
