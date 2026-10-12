module Magic
  module Cards
    FinchFormation = Creature("Finch Formation") do
      cost generic: 2, blue: 1
      creature_type("Bird Scout")
      keywords :flying
      power 2
      toughness 2
      offspring generic: 3
    end

    class FinchFormation < Creature
      # When this creature enters, target creature you control gains flying until end of turn.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class FlyingChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            give_keyword(target, :flying)
          end
        end

        def call
          game.add_choice(FlyingChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
