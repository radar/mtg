module Magic
  module Cards
    # The land back face of Strength of the Harvest. It has no mana cost.
    HavenOfTheHarvest = Card("Haven of the Harvest") do
      type "Land"
    end

    class HavenOfTheHarvest < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end

    StrengthOfTheHarvest = Aura("Strength of the Harvest") do
      cost "{2}{G/W}"
      back_face HavenOfTheHarvest
    end

    class StrengthOfTheHarvest < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature gets +1/+1 for each creature and/or enchantment you control." This Aura counts itself.
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification
          controller.permanents.count do |permanent|
            permanent.creature? || permanent.enchantment? || permanent.card.is_a?(Cards::Aura)
          end
        end

        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end
