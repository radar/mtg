module Magic
  module Cards
    StrangledCemetery = Card("Strangled Cemetery") do
      type "Land"
    end

    class StrangledCemetery < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
