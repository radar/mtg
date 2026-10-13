module Magic
  module Cards
    TalismanOfIndulgence = Artifact("Talisman of Indulgence") do
      cost generic: 2
    end

    class TalismanOfIndulgence < Artifact
      # "{T}: Add {C}."
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{T}: Add {B} or {R}. This artifact deals 1 damage to you."
      class ColoredManaAbility < Magic::TapManaAbility
        choices :black, :red

        def resolve!
          super
          deal_damage 1, to: controller, source: source
        end
      end

      def activated_abilities = [ColorlessManaAbility, ColoredManaAbility]
    end
  end
end
