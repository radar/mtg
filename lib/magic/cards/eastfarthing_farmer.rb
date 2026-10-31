module Magic
  module Cards
    EastfarthingFarmer = Creature("Eastfarthing Farmer") do
      cost generic: 2, white: 1
      creature_type "Halfling Peasant"
      power 2
      toughness 3
    end

    class EastfarthingFarmer < Creature
      # "When you do, target creature you control gets +1/+1 until end of turn for each Food you control." The Foods
      # are counted when the reflexive trigger resolves.
      class PumpChoice < Magic::Choice::Targeted
        def choice_amount = 1

        def choices = controller.creatures

        def resolve!(target:)
          foods = controller.permanents.count { _1.type?("Food") }
          pump(target, foods, foods)
        end

        def decline! = nil
      end

      # "When this creature enters, create a Food token. When you do, ..."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::Food)
          game.add_choice(PumpChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
