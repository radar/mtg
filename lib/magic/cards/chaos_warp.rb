module Magic
  module Cards
    class ChaosWarp < Instant
      card_name "Chaos Warp"
      cost generic: 2, red: 1

      def target_choices
        battlefield.permanents
      end

      def resolve!(target:)
        owner = target.owner
        target.move_zone!(to: owner.library)
        target.card.move_zone!(to: owner.library)
        owner.library.shuffle!

        top_card = owner.library.first
        return unless top_card

        owner.reveal(top_card)
        top_card.resolve! if top_card.permanent?
      end
    end
  end
end