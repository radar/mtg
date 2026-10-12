module Magic
  module Cards
    RuggedHighlands = Card("Rugged Highlands") do
      type "Land"

      enters_the_battlefield do
        actor.gain_life(1)
      end
    end

    class RuggedHighlands < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
