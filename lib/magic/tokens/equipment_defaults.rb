module Magic
  module Tokens
    # What a Permanent asks of the card it has attached to a creature (see Cards::Attachment). Include this
    # in an Equipment token class so it can be attached like an Equipment card.
    module EquipmentDefaults
      def power_modification = 0
      def toughness_modification = 0
      def keyword_grants = []
      def type_grants = []
      def grants_all_creature_types? = false
      def assigns_toughness_damage?(_creature) = false
      def forces_enchanted_to_attack? = false
      def goads_enchanted? = false
      def prevents_counters? = false
      def prevents_untapping? = false
      def does_not_untap_during_untap_step? = false
    end
  end
end
