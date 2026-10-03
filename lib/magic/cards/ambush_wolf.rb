module Magic
  module Cards
    AmbushWolf = Creature("Ambush Wolf") do
      cost generic: 2, green: 1
      creature_type("Wolf")
      keywords :flash
      power 4
      toughness 2
    end

    class AmbushWolf < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.graveyard_cards
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:exile, target: target)
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
