module Magic
  module Cards
    MindStone = Artifact("Mind Stone") do
      cost generic: 2
    end

    class MindStone < Artifact
      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class DrawAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 1),
            Costs::SelfTap.new(source),
            Costs::SelfSacrifice.new(source),
          ]
        end

        def resolve!
          controller.draw!
        end
      end

      def activated_abilities = [ManaAbility, DrawAbility]
    end
  end
end