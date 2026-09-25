module Magic
  module Cards
    MidnightTilling = Instant("Midnight Tilling") do
      cost generic: 1, green: 1
    end

    class MidnightTilling < Instant
      def resolve!
        game.choices.add(Magic::Choice::ReturnFromAmong.new(actor: self, cards: controller.mill(4), filter: ->(card) { card.permanent? }))
      end
    end
  end
end
