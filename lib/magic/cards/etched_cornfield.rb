module Magic
  module Cards
    EtchedCornfield = Card("Etched Cornfield") do
      type "Land"
    end

    class EtchedCornfield < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
