module Magic
  module Cards
    GetawayBarrel = Artifact("Getaway Barrel") do
      cost generic: 3, red: 1
    end

    class GetawayBarrel < Artifact
      # "When this artifact is put into a graveyard from the battlefield, reveal the top thirteen cards of your
      # library. Put a random creature card from among them onto the battlefield. Put the rest on the bottom of
      # your library in a random order."
      class PutIntoGraveyardTrigger < TriggeredAbility::LeaveTheBattlefield
        def should_perform? = this? && event.to.graveyard?

        def call
          library = controller.library
          revealed = library.take(13)
          trigger_effect(:reveal_cards, target: revealed) if revealed.any?

          creature = revealed.select(&:creature?).sample
          creature&.resolve!(controller: controller)

          revealed.reject { _1.equal?(creature) }.shuffle.each do |card|
            library.remove(card)
            library.push(card)
          end
        end
      end

      def ltb_triggers = [PutIntoGraveyardTrigger]
    end
  end
end
