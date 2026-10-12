module Magic
  module Cards
    MurkySewer = Card("Murky Sewer") do
      type "Land"
    end

    class MurkySewer < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
