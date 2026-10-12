# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FungalRebirth do
  include_context "two player game"

  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before do
    p1.graveyard.add(bears)
    p1.add_mana(green: 3)
  end

  def cast_fungal_rebirth(target)
    card = Card("Fungal Rebirth", owner: p1)
    p1.hand.add(card)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  def saprolings = p1.creatures.by_name("Saproling")

  it "returns the target permanent card to your hand" do
    cast_fungal_rebirth(bears)

    expect(p1.hand.cards).to include(bears)
    expect(p1.graveyard.cards).not_to include(bears)
  end

  it "creates no Saprolings if no creature died this turn" do
    cast_fungal_rebirth(bears)

    expect(saprolings.count).to eq(0)
  end

  it "creates two 1/1 Saprolings if a creature died this turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    cast_fungal_rebirth(bears)

    expect(saprolings.count).to eq(2)
    expect([saprolings.first.power, saprolings.first.toughness]).to eq([1, 1])
  end
end
