module Magic
  module Permanents
    module Enchantment
      extend Forwardable
      def_delegators :@card, :power_modification, :toughness_modification, :can_attack?, :can_block?, :keyword_grants, :type_grants, :can_activate_ability?, :does_not_untap_during_untap_step?

      attr_reader :attached_to

      def attach_to!(permanent)
        permanent.attachments << self
        @attached_to = permanent
      end
    end
  end
end
