module Magic
  module Cards
    SmolderingMarsh = Card("Smoldering Marsh") do
      type T::Land, T::Lands::Swamp, T::Lands::Mountain
    end

    class SmolderingMarsh < Card
      def enters_tapped?
        controller.lands.basic_lands.count < 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end