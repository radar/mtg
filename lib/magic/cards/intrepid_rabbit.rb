module Magic
  module Cards
    IntrepidRabbit = Creature("Intrepid Rabbit") do
      cost generic: 2, white: 1
      creature_type("Rabbit Soldier")
      power 3
      toughness 2
      offspring generic: 1
    end

    class IntrepidRabbit < Creature
      # When this creature enters, target creature you control gets +1/+1 until end of turn.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class PumpChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 1)
          end
        end

        def call
          game.add_choice(PumpChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
