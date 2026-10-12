module Magic
  module Cards
    class TakeOutTheTrash < Instant
      card_name "Take Out the Trash"
      cost generic: 1, red: 1

      class DiscardChoice < Magic::Choice::Discard
        def resolve!(card:)
          super
          draw_card
        end
      end

      class MayChoice < Magic::Choice::May
        def resolve!
          game.choices.add(DiscardChoice.new(actor: actor, player: controller))
        end
      end

      def target_choices = battlefield.creatures + battlefield.planeswalkers

      # Take Out the Trash deals 3 damage to target creature or planeswalker. If you control a Raccoon, you
      # may discard a card. If you do, draw a card.
      def resolve!(target:)
        deal_damage(3, to: target)
        game.choices.add(MayChoice.new(actor: self)) if battlefield.controlled_by(controller).creatures.any? { _1.type?("Raccoon") }
      end
    end
  end
end
