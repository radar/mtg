module Magic
  module Cards
    BleedingWoods = Card("Bleeding Woods") do
      type "Land"
    end

    class BleedingWoods < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
