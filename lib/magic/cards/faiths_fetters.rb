module Magic
  module Cards
    class FaithsFetters < Aura
      NAME = "Faith's Fetters"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      def resolve!
        controller.gain_life(4)
        attach_enchantment = Effects::AttachEnchantment.new(enchantment: self, choices: game.battlefield.creatures)
        game.add_effect(attach_enchantment)
        super
      end

      def can_attack?
        false
      end

      def can_block?
        false
      end

      def can_activate_ability?(ability)
        ability.is_a?(ManaAbility)
      end
    end
  end
end
