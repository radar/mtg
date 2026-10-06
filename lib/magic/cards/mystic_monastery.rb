module Magic
  module Cards
    MysticMonastery = Card("Mystic Monastery") do
      type "Land"
      enters_tapped
    end

    class MysticMonastery < Card
      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
