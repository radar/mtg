module Magic
  module Cards
    ThoughtVessel = Artifact("Thought Vessel") do
      cost generic: 2
    end

    class ThoughtVessel < Artifact
      # "You have no maximum hand size."
      def no_maximum_hand_size? = true

      # "{T}: Add {C}."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
