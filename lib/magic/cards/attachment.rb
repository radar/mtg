module Magic
  module Cards
    class Attachment < Card
      def resolve!(target:)
        permanent = super()
        permanent.attach_to!(target)
      end

      def keyword_grants
        []
      end

      def type_grants
        []
      end

      # "Equipped creature is all creature types."
      def grants_all_creature_types?
        false
      end

      def power_modification
        0
      end

      def toughness_modification
        0
      end

      def can_activate_ability?(_)
        true
      end
    end
  end
end
