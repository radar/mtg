module Magic
  module Cards
    RevengeOfTheRats = Sorcery("Revenge of the Rats") do
      cost generic: 2, black: 2
      flashback Costs::Mana.new(generic: 2, black: 2)
    end

    class RevengeOfTheRats < Sorcery
      RatToken = Token.create "Rat" do
        creature_type "Rat"
        power 1
        toughness 1
        colors :black
      end

      def resolve!
        trigger_effect(:create_token, token_class: RatToken, amount: controller.graveyard.creatures.count, enters_tapped: true)
      end
    end
  end
end
