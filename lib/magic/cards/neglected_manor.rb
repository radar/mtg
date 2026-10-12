module Magic
  module Cards
    NeglectedManor = Card("Neglected Manor") do
      type "Land"
    end

    class NeglectedManor < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
