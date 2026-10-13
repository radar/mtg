module Magic
  module Cards
    HopToIt = Sorcery("Hop to It") do
      cost generic: 2, white: 1
    end

    class HopToIt < Sorcery
      RabbitToken = Token.create "Rabbit" do
        creature_type "Rabbit"
        power 1
        toughness 1
        colors :white
      end

      def resolve!
        create_token(token:RabbitToken, amount: 3)
      end
    end
  end
end
