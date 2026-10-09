module Magic
  module Cards
    BardTheBowman = Creature("Bard the Bowman") do
      cost generic: 1, white: 1, blue: 1
      legendary_creature_type("Human Archer")
      keywords :reach
      power 1
      toughness 3
    end

    class BardTheBowman < Creature
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
            trigger_effect(:grant_keyword, target: target, keyword: :lifelink)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
