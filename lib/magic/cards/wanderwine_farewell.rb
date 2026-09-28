module Magic
  module Cards
    WanderwineFarewell = Sorcery("Wanderwine Farewell") do
      cost generic: 5, blue: 2
      type T::Kindred, T::Sorcery, T::Creatures["Merfolk"]
      convoke
    end

    class WanderwineFarewell < Sorcery
      MerfolkToken = Token.create "Merfolk" do
        creature_type "Merfolk"
        power 1
        toughness 1
        colors :white, :blue
      end

      def target_choices
        battlefield.nonland
      end

      def resolve!(targets:)
        targets = targets.first(2)
        targets.each { |target| trigger_effect(:return_to_owners_hand, target: target) }
        game.tick!

        return unless controller.creatures.by_type("Merfolk").any?

        trigger_effect(:create_token, token_class: MerfolkToken, amount: targets.count)
      end
    end
  end
end
