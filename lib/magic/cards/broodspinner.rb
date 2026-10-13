module Magic
  module Cards
    Broodspinner = Creature("Broodspinner") do
      cost "{B}{G}"
      creature_type "Spider"
      keywords :reach
      power 2
      toughness 3
    end

    class Broodspinner < Creature
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        colors :black, :green
        power 1
        toughness 1
        keywords :flying
      end

      # "When this creature enters, surveil 2."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
        end
      end

      # "{4}{B}{G}, {T}, Sacrifice this creature: Create a number of 1/1 black and green Insect creature tokens with
      # flying equal to the number of card types among cards in your graveyard."
      class CreateInsects < Magic::ActivatedAbility
        costs "{4}{B}{G}, {T}, Sacrifice {this}"

        def resolve!
          controller.graveyard.card_type_count.times { create_token(token:InsectToken) }
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [CreateInsects]
    end
  end
end
