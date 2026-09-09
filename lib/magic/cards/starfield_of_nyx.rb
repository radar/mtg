module Magic
  module Cards
    StarfieldOfNyx = Enchantment("Starfield of Nyx") do
      cost generic: 4, white: 1
    end

    class StarfieldOfNyx < Enchantment
      class EnchantmentCreatureTypes < Abilities::Static::TypeGrant
        def type_grants
          [T::Creature]
        end

        def applicable_targets
          return [] if source.controller.permanents.enchantments.count < 5

          source.controller.permanents.enchantments.reject { |permanent| permanent.card.is_a?(Aura) || permanent == source }
        end
      end

      class EnchantmentPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets
          return [] if source.controller.permanents.enchantments.count < 5

          source.controller.permanents.enchantments.reject { |permanent| permanent.card.is_a?(Aura) || permanent == source }
        end

        def power_modification
          source.mana_value
        end

        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [EnchantmentCreatureTypes, EnchantmentPowerAndToughness]
    end
  end
end