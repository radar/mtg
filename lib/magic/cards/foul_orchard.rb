module Magic
  module Cards
    FoulOrchard = Card("Foul Orchard") do
      type "Land"
    end

    class FoulOrchard < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
