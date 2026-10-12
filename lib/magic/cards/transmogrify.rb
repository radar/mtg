module Magic
  module Cards
    Transmogrify = Sorcery("Transmogrify") do
      cost generic: 3, red: 1
    end

    class Transmogrify < Sorcery
      def target_choices = battlefield.creatures

      # "Exile target creature. That creature's controller reveals cards from the top of their
      # library until they reveal a creature card. That player puts that card onto the
      # battlefield, then shuffles the rest into their library."
      def resolve!(target:)
        player = target.controller
        trigger_effect(:exile, target:)

        revealed = []
        creature = nil
        player.library.cards.each do |card|
          revealed << card
          if card.creature?
            creature = card
            break
          end
        end
        trigger_effect(:reveal_cards, target: revealed) if revealed.any?
        creature&.resolve!
        player.shuffle!
      end
    end
  end
end
