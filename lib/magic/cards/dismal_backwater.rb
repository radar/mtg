module Magic
  module Cards
    DismalBackwater = Card("Dismal Backwater") do
      type "Land"

      enters_the_battlefield do
        permanent.controller.gain_life(1)
      end
    end

    class DismalBackwater < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
