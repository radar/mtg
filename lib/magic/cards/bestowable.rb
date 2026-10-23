module Magic
  module Cards
    # Included by the `bestow` DSL (`Card.bestow`). A card cast for its bestow cost (`Actions::Cast::Bestowed`) resolves
    # attached to its target creature as an Aura (`Permanent#bestowed_now?`). If the target is gone by then, it
    # resolves as a creature instead (702.103e).
    #
    # While bestowed it is an attachment of the creature, so the card answers the same questions an Aura does
    # (`power_modification`, `keyword_grants`, ...); override the ones the Aura half of the card changes.
    module Bestowable
      def resolve!(target: nil, bestowed: false, enters_tapped: enters_tapped?, kicked: false, controller: owner, mana_spent: {}, evoked: false, value_for_x: nil, impending: false)
        args = { enters_tapped:, kicked:, controller:, mana_spent:, evoked:, value_for_x:, impending: }
        return super(**args) unless bestowed && game.battlefield.creatures.include?(target)

        permanent = super(**args, attach_to: target)
        permanent.bestowed = true
        permanent.apply_continuous_effects!
        permanent
      end

      def can_enchant?(host, aura:) = host.creature?

      def type_grants = []

      def power_modification = 0

      def toughness_modification = 0

      def grants_all_creature_types? = false

      def assigns_toughness_damage?(_creature) = false

      def does_not_untap_during_untap_step? = false

      def prevents_untapping? = false

      def prevents_counters? = false
    end
  end
end
