module Magic
  module Cards
    ChromaticOrrery = Artifact("Chromatic Orrery") do
      cost generic: 7
    end

    class ChromaticOrrery < Artifact
      class TapAbility < TapManaAbility
        def resolve!
          controller.add_mana(colorless: 5)
        end
      end

      class DrawAbility < ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 5),
            Costs::SelfTap.new(source),
          ]
        end

        def resolve!
          colors = game.battlefield.permanents
            .controlled_by(source.controller)
            .flat_map(&:colors)
            .uniq
          colors.count.times { source.controller.draw! }
        end
      end

      class AnyColorForAnyCost < Abilities::Static::AnyColorForAnyCost
      end

      def activated_abilities = [TapAbility, DrawAbility]
      def static_abilities = [AnyColorForAnyCost]
    end
  end
end
