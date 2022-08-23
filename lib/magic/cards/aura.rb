module Magic
  module Cards
    class Aura < Card
      def single_target?
        true
      end

      def resolve!(target:)
        permanent = super(controller)
        permanent.attach_to!(target)
      end

      def power_buff
        0
      end

      def toughness_buff
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
