module Magic
  module Cards
    class CrumbAndGetIt < Instant
      card_name "Crumb and Get It"
      cost white: 1
      gift :food

      def target_choices = battlefield.controlled_by(controller).creatures

      # Target creature you control gets +2/+2 until end of turn. If the gift was promised, that
      # creature also gains indestructible until end of turn.
      def resolve!(target:)
        pump(target, 2, 2)
        trigger_effect(:grant_keyword, target: target, keyword: :indestructible) if gift_promised?
      end
    end
  end
end
