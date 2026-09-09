module Magic
  module Cards
    GreaterAuramancy = Enchantment("Greater Auramancy") do
      cost generic: 1, white: 1
    end

    class GreaterAuramancy < Enchantment
      class OtherEnchantmentShroud < Abilities::Static::KeywordGrant
        keyword_grants Keywords::SHROUD

        applicable_targets do
          source.controller.permanents.enchantments - [source]
        end
      end

      class EnchantedCreatureShroud < Abilities::Static::KeywordGrant
        keyword_grants Keywords::SHROUD

        applicable_targets do
          source.controller.creatures.select { |creature| creature.attachments.any? }
        end
      end

      def static_abilities = [OtherEnchantmentShroud, EnchantedCreatureShroud]
    end
  end
end