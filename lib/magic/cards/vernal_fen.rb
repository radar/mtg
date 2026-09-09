module Magic
  module Cards
    VernalFen = Card("Vernal Fen") do
      type T::Land, T::Lands::Swamp, T::Lands::Forest
    end

    class VernalFen < Card
      def enters_tapped? = controller.lands.basic_lands.count < 2

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end