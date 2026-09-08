module Magic
  module Cards
    SandsteppeCitadel = Card("Sandsteppe Citadel") do
      type "Land"
    end

    class SandsteppeCitadel < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end