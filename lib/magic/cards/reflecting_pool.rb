module Magic
  module Cards
    ReflectingPool = Card("Reflecting Pool") do
      type "Land"
    end

    class ReflectingPool < Card
      class ManaAbility < Magic::TapManaAbility
        # "Add one mana of any type that a land you control could produce." Abilities that reflect other lands
        # (including this one, on any land, however it was gained) contribute nothing, or they would ask each other forever.
        def reflects_other_lands? = true

        def choices
          controller.lands.flat_map(&:activated_abilities)
            .select { |ability| ability.is_a?(Magic::ManaAbility) }
            .reject(&:reflects_other_lands?)
            .flat_map(&:choices).uniq
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end