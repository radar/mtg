module Magic
  module Cards
    FurorOfTheBitten = Aura("Furor of the Bitten") do
      cost red: 1
    end

    class FurorOfTheBitten < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature gets +2/+2 and attacks each combat if able."
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      def static_abilities = [PowerAndToughnessModification]

      def forces_enchanted_to_attack? = true
    end
  end
end
