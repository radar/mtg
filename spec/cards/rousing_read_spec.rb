require 'spec_helper'

RSpec.describe Magic::Cards::RousingRead do
  include_context "two player game"

  let(:card) { Card("Rousing Read") }
  let!(:wood_elves) { ResolvePermanent("Wood Elves") }

  it "draws two cards, discards a card, and gives +1/+1 and flying to a creature" do
    p1.add_mana(blue: 3)
    expect(p1).to receive(:draw!).twice

    p1.cast(card: card) do
      _1.pay_mana(generic: { blue: 2 }, blue: 1)
      _1.targeting(wood_elves)
    end

    game.stack.resolve!

    choice = game.choices.last
    game.resolve_choice!(card: choice.cards.first)

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
    expect(wood_elves).to be_flying
  end
end
