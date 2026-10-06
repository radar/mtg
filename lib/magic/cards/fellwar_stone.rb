module Magic
  module Cards
    FellwarStone = Artifact("Fellwar Stone") do
      cost generic: 2
    end

    class FellwarStone < Artifact
      COLORS = %i[white blue black red green].freeze

      class ManaAbility < Magic::TapManaAbility
        # Any colour a land an opponent controls could produce. Like Exotic Orchard, it ignores other copies of
        # itself (they would each ask the other), and colourless is not a colour.
        def choices
          game.opponents(controller)
            .flat_map(&:lands)
            .flat_map(&:activated_abilities)
            .select { |ability| ability.is_a?(Magic::ManaAbility) }
            .reject { |ability| ability.is_a?(ExoticOrchard::ManaAbility) }
            .flat_map(&:choices)
            .uniq & COLORS
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
