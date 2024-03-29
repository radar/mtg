module Magic
  module Cards
    class FaithsFetters < Aura
      NAME = "Faith's Fetters"
      COST = { generic: 3, white: 1 }

      def target_choices
        battlefield.permanents
      end

      def resolve!(target:)
        controller.gain_life(4)
        super
      end

      def can_attack?
        false
      end

      def can_block?(_)
        false
      end

      def can_activate_ability?(ability)
        ability.is_a?(ManaAbility)
      end
    end
  end
end
