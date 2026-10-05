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
            # Two Exotic Orchards each asking what the other could produce would never finish: an Orchard's colours
            # come from the other lands only (rulings: they produce nothing for each other).
            .reject { |ability| ability.is_a?(ExoticOrchard::ManaAbility) }
            .flat_map(&:choices)
            .uniq
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end