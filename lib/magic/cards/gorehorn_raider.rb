module Magic
  module Cards
    GorehornRaider = Creature("Gorehorn Raider") do
      cost generic: 4, red: 1
      creature_type("Minotaur Pirate")
      power 4
      toughness 4
    end

    class GorehornRaider < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          super && (game.current_turn.events.any? { |e| e.is_a?(Events::FinalAttackersDeclared) && e.active_player == controller && e.attacks.any? })
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.any_target
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: 2)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
