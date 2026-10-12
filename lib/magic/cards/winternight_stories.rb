module Magic
  module Cards
    WinternightStories = Sorcery("Winternight Stories") do
      cost generic: 2, blue: 1
      harmonize Costs::Mana.new(generic: 4, blue: 1)
    end

    class WinternightStories < Sorcery
      def resolve!
        draw_cards(3)
        game.choices.add(Magic::Choice::DiscardUnless.new(actor: self, amount: 2, card_type: "Creature"))
      end
    end
  end
end
