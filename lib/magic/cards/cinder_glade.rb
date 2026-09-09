module Magic
  module Cards
    CinderGlade = Card("Cinder Glade") do
      type T::Land, T::Lands::Mountain, T::Lands::Forest
    end

    class CinderGlade < Card
      def enters_tapped? = controller.lands.basic_lands.count < 2

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end