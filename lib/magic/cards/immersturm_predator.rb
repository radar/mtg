module Magic
  module Cards
    ImmersturmPredator = Creature("Immersturm Predator") do
      cost generic: 2, black: 1, red: 1
      creature_type("Vampire Dragon")
      keywords :flying
      power 3
      toughness 3
    end

    class ImmersturmPredator < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "Sacrifice another creature"

        def resolve!
          trigger_effect(:grant_keyword, target: source, keyword: :indestructible)
          trigger_effect(:tap, target: source)
        end
      end

      def activated_abilities = [ActivatedAbility]

      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.graveyard_cards
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:exile, target: target)
            finish
          end

          def decline! = finish

          def finish
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          choice.choices.any? ? game.add_choice(choice) : choice.finish
        end
      end

      def event_handlers = super.merge({ Events::PermanentTapped => BecomesTappedTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
