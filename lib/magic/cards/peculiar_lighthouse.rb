module Magic
  module Cards
    PeculiarLighthouse = Card("Peculiar Lighthouse") do
      type "Land"
    end

    class PeculiarLighthouse < Card
      # "This land enters tapped unless a player has 13 or less life."
      def enters_tapped? = game.players.none? { |player| player.life <= 13 }

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
