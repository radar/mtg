module Magic
  module Cards
    class Aura < Card
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
