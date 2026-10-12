module Magic
  module Cards
    PlumecreedEscort = Creature("Plumecreed Escort") do
      cost generic: 1, blue: 1
      creature_type("Bird Scout")
      keywords :flash, :flying
      power 2
      toughness 1
    end

    class PlumecreedEscort < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
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
