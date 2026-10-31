module Magic
  module Cards
    SwarmingOfMoria = Sorcery("Swarming of Moria") do
      cost generic: 2, red: 1
    end

    class SwarmingOfMoria < Sorcery
      # "Create a Treasure token. Amass Orcs 2."
      def resolve!
        create_token(token: Tokens::Treasure)
        Magic::Amass.call(source: self, controller: controller, amount: 2, subtype: "Orc")
        super
      end
    end
  end
end
