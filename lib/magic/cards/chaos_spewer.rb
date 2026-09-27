module Magic
  module Cards
    ChaosSpewer = Creature("Chaos Spewer") do
      cost generic: 2, black_or_red: 1
      creature_type("Goblin Warlock")
      power 5
      toughness 4
    end

    class ChaosSpewer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayPayChoice < Magic::Choice::May
          def resolve!(payment: {})
            controller.pay_mana(payment)
          end

          def decline!
            game.add_choice(Magic::Choice::Blight.new(actor: actor, amount: 2)) if Magic::Choice::Blight.possible?(controller, game)
          end
        end

        def call
          game.choices.add(MayPayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
