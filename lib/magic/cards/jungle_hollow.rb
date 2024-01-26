module Magic
  module Cards
    JungleHollow = Card("Jungle Hollow") do
      type "Land"
      enters_the_battlefield do
        permanent.trigger_effect(:gain_life, life: 1)
      end
    end

    class JungleHollow < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
