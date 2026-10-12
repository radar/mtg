module Magic
  module Cards
    CuriousForager = Creature("Curious Forager") do
      cost generic: 2, green: 1
      creature_type("Squirrel Druid")
      power 3
      toughness 2
    end

    class CuriousForager < Creature
      # When this creature enters, you may forage. When you do, return target permanent card from your
      # graveyard to your hand.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.permanents

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        class ForageChoice < Magic::Choice::Forage
          def after_forage
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = ForageChoice.new(actor: actor)
            game.choices.add(choice) if choice.possible?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
