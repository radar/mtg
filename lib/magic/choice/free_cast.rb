module Magic
  class Choice
    # "You may cast target instant or sorcery card from your graveyard without paying its mana cost. If that
    # spell would be put into your graveyard, exile it instead." Once the card is chosen, `FreeCast.start`
    # casts it (asking for its target first when it needs one).
    class FreeCast < Magic::Choice::Targeted
      def self.start(actor:, card:)
        choice = new(actor: actor, card: card)
        if choice.pending_target?
          actor.game.add_choice(choice) if choice.choices.any?
        else
          choice.cast!(nil)
        end
      end

      def initialize(actor:, card:)
        @card = card
        super(actor: actor)
      end

      def pending_target? = @card.respond_to?(:target_choices) && !(@card.respond_to?(:multi_target?) && @card.multi_target?)

      def choices = @card.target_choices

      def choice_amount = 1

      def resolve!(target:) = cast!(target)

      def cast!(target)
        @card.exile_once!
        action = controller.prepare_cast(card: @card, by_effect: true)
        action.mana_cost = {}
        action.targeting(target) if target
        game.take_action(action)
      end
    end
  end
end
