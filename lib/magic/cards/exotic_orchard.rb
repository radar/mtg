module Magic
  module Cards
    ExoticOrchard = Card("Exotic Orchard") do
      type "Land"
    end

    class ExoticOrchard < Card
      class ManaAbility < Magic::TapManaAbility
        def choices
          game.opponents(controller)
            .flat_map(&:lands)
            .flat_map(&:activated_abilities)
            .select { |ability| ability.is_a?(Magic::ManaAbility) }
            .flat_map(&:choices)
            .uniq
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end