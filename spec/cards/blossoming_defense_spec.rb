# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BlossomingDefense do
  include_context "two player game"

  it "gives a creature you control +2/+2 and hexproof until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 1)

    p1.cast(card: Card("Blossoming Defense", owner: p1)) { |a| a.pay_mana(green: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.power).to eq(4)
    expect(bears.toughness).to eq(4)
    expect(bears.hexproof?).to be(true)
  end

  it "cannot target a creature you don't control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    card = Card("Blossoming Defense", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 1)

    expect { p1.cast(card: card) { |a| a.pay_mana(green: 1).targeting(bears) } }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
