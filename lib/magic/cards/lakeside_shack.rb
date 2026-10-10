module Magic
  module Cards
    LakesideShack = Card("Lakeside Shack") do
      type "Land"
    end

    class LakesideShack < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :green, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
