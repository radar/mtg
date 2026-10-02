module Magic
  module Cards
    ViashinoPyromancer = Creature("Viashino Pyromancer") do
      cost generic: 1, red: 1
      creature_type("Lizard Wizard")
      power 2
      toughness 1
    end

    class ViashinoPyromancer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.players + battlefield.planeswalkers
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
