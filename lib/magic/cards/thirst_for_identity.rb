module Magic
  module Cards
    ThirstForIdentity = Instant("Thirst for Identity") do
      cost generic: 2, blue: 1
    end

    class ThirstForIdentity < Instant
      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 3)
        game.choices.add(Magic::Choice::DiscardUnless.new(actor: self, amount: 2, card_type: "Creature"))
      end
    end
  end
end
