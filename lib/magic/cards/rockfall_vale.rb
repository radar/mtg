module Magic
  module Cards
    RockfallVale = Card("Rockfall Vale") do
      type "Land"
    end

    class RockfallVale < Card
      def enters_tapped?
        controller.lands.count < 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end