module Magic
  module Cards
    class Brainsurge < Instant
      card_name "Brainsurge"
      cost generic: 2, blue: 1

      # "Put two cards from your hand on top of your library in any order." Answer with `targets:` listed top
      # first. Not a target; declining puts the first cards of the hand back.
      class PutBackChoice < Magic::Choice::Targeted
        def targets? = false

        def choices = controller.hand.cards.to_a

        def choice_amount = [2, controller.hand.cards.size].min

        def prompt = "Put two cards from your hand on top of your library in any order (top card first)."

        def resolve!(targets:)
          targets = Array(targets)
          raise ArgumentError, "Choose #{choice_amount} different cards." unless targets.size == choice_amount && targets.uniq.size == targets.size
          raise ArgumentError, "Choose cards from your hand." unless targets.all? { controller.hand.cards.include?(_1) }

          targets.reverse_each do |card|
            controller.hand.remove(card)
            controller.library.add(card)
          end
        end

        def decline!
          resolve!(targets: choices.first(choice_amount))
        end
      end

      # "Draw four cards, then put two cards from your hand on top of your library in any order."
      def resolve!
        draw_cards 4
        game.add_choice(PutBackChoice.new(actor: self)) if controller.hand.cards.any?
      end
    end
  end
end
