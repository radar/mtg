module Magic
  module Cards
    class MightOfTheMeek < Instant
      card_name "Might of the Meek"
      cost red: 1

      def target_choices = battlefield.creatures

      # Target creature gains trample until end of turn. It also gets +1/+0 until end of turn if you control a
      # Mouse. Draw a card.
      def resolve!(target:)
        give_keyword(target, :trample)
        if battlefield.controlled_by(controller).creatures.any? { _1.type?("Mouse") }
          pump(target, 1, 0)
        end
        draw_card
      end
    end
  end
end
