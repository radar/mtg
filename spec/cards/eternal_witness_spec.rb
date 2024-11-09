require "spec_helper"

RSpec.describe Magic::Cards::EternalWitness do
  include_context "two player game"

  context "when it enters" do
    subject { Card("Eternal Witness") }

    before do
      p1.graveyard.add(Card("Wood Elves"))
    end

    it "can choose to return wood elves" do
      p1.add_mana(green: 3)
      p1.cast(card: subject) do
        _1.auto_pay_mana
      end

      game.stack.resolve!

      game.resolve_choice!(target: p1.graveyard.first)

      expect(p1.hand.by_name("Wood Elves")).to be_one
      expect(p1.graveyard.by_name("Wood Elves")).to be_none
    end
  end
end
