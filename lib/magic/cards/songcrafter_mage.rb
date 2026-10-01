module Magic
  module Cards
    SongcrafterMage = Creature("Songcrafter Mage") do
      cost green: 1, blue: 1, red: 1
      creature_type("Human Bard")
      keywords :flash
      power 3
      toughness 2
    end

    class SongcrafterMage < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.instant? || _1.sorcery? }
          end

          def choice_amount = 1

          def resolve!(target:)
            target.grant_harmonize_until_end_of_turn!
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
