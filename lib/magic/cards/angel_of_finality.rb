module Magic
  module Cards
    AngelOfFinality = Creature("Angel of Finality") do
      cost generic: 3, white: 1
      creature_type("Angel")
      keywords :flying
      power 3
      toughness 4
    end

    class AngelOfFinality < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.players
          end

          def choice_amount = 1

          def resolve!(target:)
            [*target.graveyard.cards].each { trigger_effect(:exile, target: _1) }
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
