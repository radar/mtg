module Magic
  module Cards
    class Aura < Card
      TYPE_LINE = "Enchantment -- Aura"

      def single_target?
        true
      end

      def resolve!(target:)
        permanent = super()
        permanent.attach_to!(target)
      end

      def power_modification
        0
      end

      def toughness_modification
        0
      end

      def keyword_grants
        []
      end

      def type_grants
        []
      end

      def can_activate_ability?(_)
        true
      end
    end
  end
end
