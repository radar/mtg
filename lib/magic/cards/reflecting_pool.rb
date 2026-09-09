module Magic
  module Cards
    ReflectingPool = Card("Reflecting Pool") do
      type "Land"
    end

    class ReflectingPool < Card
      class ManaAbility < Magic::TapManaAbility
        def choices
          controller.lands.flat_map(&:activated_abilities)
            .select { |ability| ability.is_a?(Magic::ManaAbility) }
            .flat_map(&:choices).uniq
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end