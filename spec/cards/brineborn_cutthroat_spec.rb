# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrinebornCutthroat do
  include_context "two player game"

  let!(:cutthroat) { ResolvePermanent("Brineborn Cutthroat", owner: p1) }

  def counters = cutthroat.counters.of_type(Magic::Counters["+1/+1"]).count

  it "is a 2/1 Merfolk Pirate with flash" do
    expect([cutthroat.power, cutthroat.toughness]).to eq([2, 1])
    expect(cutthroat.card.has_keyword?(:flash)).to eq(true)
  end

  it "gets a +1/+1 counter when you cast a spell during an opponent's turn" do
    go_to_main_phase_for!(p2)
    p1.add_mana(white: 2)
    p1.cast(card: Card("Adamant Will", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(cutthroat) }
    game.settle!

    expect(counters).to eq(1)
  end

  it "doesn't get a counter when you cast a spell during your own turn" do
    go_to_main_phase!
    p1.add_mana(white: 2)
    p1.cast(card: Card("Adamant Will", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(cutthroat) }
    game.settle!

    expect(counters).to eq(0)
  end
end
