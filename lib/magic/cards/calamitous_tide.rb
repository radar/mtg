module Magic
  module Cards
    class CalamitousTide < Sorcery
      card_name "Calamitous Tide"
      cost generic: 4, blue: 2

      class DiscardChoice < Magic::Choice::Discard
      end

      def multi_target? = true

      def distinct_targets? = true

      def target_choices = [battlefield.creatures, battlefield.creatures]

      # Return up to two target creatures to their owners' hands. Draw two cards, then discard a card.
      def resolve!(targets: [])
        targets.each { trigger_effect(:return_to_owners_hand, target: _1) }
        trigger_effect(:draw_cards, number_to_draw: 2)
        game.choices.add(DiscardChoice.new(actor: self, player: controller)) if controller.hand.any?
      end
    end
  end
end
