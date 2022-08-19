module Magic
  module Cards
    class Aura < Card
      attr_reader :attached_to

      def single_target?
        true
      end

      def enchant_creature(target:)
        @attached_to = target
        target.attachments << self
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
