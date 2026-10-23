module Magic
  class Choice
    # "Copy it. You may cast the copy" for a card that isn't on the stack (exiled with Arcane Bombardment, The Tale of
    # Tamiyo's chapter IV): declining does nothing; accepting asks for the copy's target if it needs one, then resolves the
    # copy directly (`CopyEffect.resolve!`), without paying its cost. `game.resolve_choice!` accepts, `game.skip_choice!`
    # declines.
    class MayCastCopy < May
      # The target of the copy, for a card that has one.
      class TargetChoice < Targeted
        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def choice_amount = 1

        def choices
          method = @card.method(:target_choices)
          method.arity == 1 ? @card.target_choices(controller) : @card.target_choices
        end

        def resolve!(target:)
          CopyEffect.resolve!(@card, targets: [target])
        end
      end

      attr_reader :card

      def initialize(actor:, card:)
        super(actor: actor)
        @card = card
      end

      def prompt = "Cast a copy of #{card.name}?"

      def resolve!
        CopyEffect.notify_copied!(game, spell: card, player: controller)
        return CopyEffect.resolve!(card, targets: []) unless card.respond_to?(:target_choices)

        choice = TargetChoice.new(actor: actor, card: card)
        if choice.choices.any?
          game.add_choice(choice)
        else
          CopyEffect.resolve!(card, targets: [])
        end
      end
    end
  end
end
