module Magic
  module Cards
    class StarfallInvocation < Sorcery
      card_name "Starfall Invocation"
      cost generic: 3, white: 2
      gift :card

      # Return a creature card put into your graveyard this way to the battlefield under your control.
      class ReturnChoice < Magic::Choice::Targeted
        def initialize(actor:, cards:)
          @cards = cards
          super(actor: actor)
        end

        def choices = @cards

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)
        end
      end

      # Destroy all creatures. If the gift was promised, return a creature card put into your
      # graveyard this way to the battlefield under your control.
      def resolve!
        before = controller.graveyard.creatures.to_a
        battlefield.creatures.each { trigger_effect(:destroy_target, target: _1) }
        game.settle!
        return unless gift_promised?

        choice = ReturnChoice.new(actor: self, cards: controller.graveyard.creatures.to_a - before)
        game.add_choice(choice) if choice.choices.any?
      end
    end
  end
end
