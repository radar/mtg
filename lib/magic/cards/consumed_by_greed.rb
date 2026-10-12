module Magic
  module Cards
    class ConsumedByGreed < Instant
      card_name "Consumed by Greed"
      cost generic: 1, black: 2
      gift :card

      # Target opponent sacrifices the creature of their choice with the greatest power among
      # creatures they control.
      class SacrificeChoice < Magic::Choice::Targeted
        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        def controller = @player

        def choices
          greatest = @player.creatures.map(&:power).max
          @player.creatures.select { _1.power == greatest }
        end

        def choice_amount = 1

        def resolve!(target:)
          target.sacrifice!
        end
      end

      # With the gift promised there is a second target: a creature card in your graveyard.
      def multi_target? = gift_promised?

      def target_choices
        return game.opponents(controller) unless gift_promised?

        [game.opponents(controller), controller.graveyard.creatures]
      end

      def resolve!(targets:)
        opponent = targets.first
        choice = SacrificeChoice.new(actor: self, player: opponent)
        game.add_choice(choice) if choice.choices.any?
        targets[1]&.move_to_hand! if gift_promised?
      end
    end
  end
end
