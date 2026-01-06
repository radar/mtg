require 'spec_helper'

RSpec.describe Magic::Cards::TownGreeter do
  include_context "two player game"

  let(:card) { Card("Town Greeter") }

  before do
    p1.hand.add(card)
    2.times { p1.library.add(Card("Island")) }
    2.times { p1.library.add(Card)}
  end

  describe "entering the battlefield" do
    it "mills 4, can choose to return a land card to hand" do
      p1.add_mana(green: 2)
      p1.cast(card: card) do
        _1.pay_mana(generic: { green: 1}, green: 1)
      end

      game.stack.resolve!
      game.tick!

      expect(p1.graveyard.count).to eq(4)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::TownGreeter::Choice)
      expect(choice.choices.count).to eq(4)

      choice.resolve!(target: choice.choices.first)
      game.tick!

      expect(p1.hand.by_name("Island").count).to eq(1)
      expect(p1.graveyard.count).to eq(3)
    end
  end
end
