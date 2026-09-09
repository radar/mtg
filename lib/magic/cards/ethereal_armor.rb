module Magic
  module Cards
    EtherealArmor = Aura("Ethereal Armor") do
      cost white: 1
    end

    class EtherealArmor < Aura
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification
          controller.permanents.count { |permanent| permanent.enchantment? || permanent.card.is_a?(Cards::Aura) }
        end

        alias_method :toughness_modification, :power_modification
      end

      class FirstStrikeGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE
        applies_to_target
      end

      def static_abilities = [PowerAndToughnessModification, FirstStrikeGrant]
    end
  end
end