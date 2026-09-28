module Magic
  module Cards
    Graveshifter = Creature("Graveshifter") do
      cost generic: 3, black: 1
      creature_type("Shapeshifter")
      keywords :changeling
      power 2
      toughness 2
    end

    class Graveshifter < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          class TargetChoice < Magic::Choice::Targeted
            def choices
              controller.graveyard.cards.creatures
            end

            def choice_amount = 1

            def resolve!(target:)
              target.move_to_hand!
            end
          end

          def resolve!
            choice = TargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          return if (controller.graveyard.cards.creatures).none?
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
