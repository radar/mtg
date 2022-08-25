module Magic
  module Cards
    class FaithsFetters < Aura
      NAME = "Faith's Fetters"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 3, white: 1 }

      def target_choices
        battlefield.permanents
      end

      def resolve!(controller, target:)
        controller.gain_life(4)
        super
      end

      def can_attack?
        false
      end

      def can_block?
        false
      end

      def can_activate_ability?(ability)
        ability < ManaAbility
      end
    end
  end
end
