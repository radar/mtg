module Magic
  module Cards
    RallyAtTheHornburg = Sorcery("Rally at the Hornburg") do
      cost generic: 1, red: 1
    end

    class RallyAtTheHornburg < Sorcery
      # "Create two 1/1 white Human Soldier creature tokens. Humans you control gain haste until end of turn."
      def resolve!
        create_token(token: Tokens::HumanSoldier, amount: 2)
        controller.creatures.select { _1.type?("Human") }.each do |human|
          human.grant_keyword(Keywords::HASTE, until_eot: true)
        end
        super
      end
    end
  end
end
