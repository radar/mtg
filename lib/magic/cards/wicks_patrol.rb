module Magic
  module Cards
    WicksPatrol = Creature("Wick's Patrol") do
      cost generic: 4, black: 2
      creature_type("Rat Warlock")
      power 5
      toughness 3
    end

    class WicksPatrol < Creature
      # When this creature enters, mill three cards. When you do, target creature an opponent controls gets -X/-X
      # until end of turn, where X is the greatest mana value among cards in your graveyard.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ShrinkChoice < Magic::Choice::Targeted
          def choices = battlefield.not_controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            x = controller.graveyard.map(&:mana_value).max || 0
            pump(target, -x, -x)
          end
        end

        def call
          controller.mill(3)
          choice = ShrinkChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
