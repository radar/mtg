module Magic
  module Permanents
    module Enchantment
      extend Forwardable
      def_delegators :@card, :can_activate_ability?, :does_not_untap_during_untap_step?

      attr_reader :attached_to

      def attach_to!(permanent)
        permanent.attachments << self
        @attached_to = permanent
      end

      def power_modification
        power_and_toughness_modifications.sum(&:power_modification)
      end

      private

      def power_and_toughness_modifications
        static_abilities.select { |ability| ability.is_a?(Abilities::Static::PowerAndToughnessModification) }
      end
    end
  end
end
