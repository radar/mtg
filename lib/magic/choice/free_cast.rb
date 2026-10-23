module Magic
  class Choice
    # "You may cast target instant or sorcery card from your graveyard without paying its mana cost. If that
    # spell would be put into your graveyard, exile it instead." Once the card is chosen, `FreeCast.start`
    # casts it (asking for its target first when it needs one).
    class FreeCast < Magic::Choice::Targeted
      # `exile_after: false` for "cast ... without paying its mana cost" with no "exile it instead" rider.
      def self.start(actor:, card:, exile_after: true)
        choice = new(actor: actor, card: card, exile_after: exile_after)
        if choice.pending_target?
          actor.game.add_choice(choice) if choice.choices.any?
        else
          choice.cast!(nil)
        end
      end

      def initialize(actor:, card:, exile_after: true)
        @card = card
        @exile_after = exile_after
        super(actor: actor)
      end

      def pending_target? = @card.respond_to?(:target_choices) && !(@card.respond_to?(:multi_target?) && @card.multi_target?)

      def choices = @card.target_choices

      def choice_amount = 1

      def resolve!(target:) = cast!(target)

      def cast!(target)
        @card.exile_once! if @exile_after
        action = controller.prepare_cast(card: @card, by_effect: true)
        action.mana_cost = {}
        action.targeting(target) if target
        game.take_action(action)
      end
    end
  end
end
