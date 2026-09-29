module Magic
  module Behold
    # "When this creature leaves the battlefield, return the exiled card to its owner's hand."
    # For a creature cast with "behold ... and exile it": list it as `ltb_triggers`.
    class ReturnExiledCardTrigger < TriggeredAbility::LeaveTheBattlefield
      def call
        card = actor.beheld_card
        return unless card&.zone&.exile?

        card.move_to_hand!(card.owner)
      end
    end
  end
end
