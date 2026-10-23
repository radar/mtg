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
          super && declared_attackers_this_turn?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.any_target
          end

          def choice_amount = 1

          def resolve!(target:)
            deal_damage(2, to: target)
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
