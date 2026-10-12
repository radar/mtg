module Magic
  module Cards
    ThistledownPlayers = Creature("Thistledown Players") do
      cost generic: 2, white: 1
      creature_type("Mouse Bard")
      power 3
      toughness 3
    end

    class ThistledownPlayers < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.nonland
          end

          def choice_amount = 1

          def resolve!(target:)
            target.untap!
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
