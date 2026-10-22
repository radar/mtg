# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnfathomableTruths do
  include_context "two player game"

  let(:card) { Card("Unfathomable Truths", owner: p1) }

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a colorless instant costing {4}{U}" do
    expect(card.colors).to be_empty
    expect(card.type?("Instant")).to be(true)
    expect(card.cost.mana_value).to eq(5)
  end

  it "draws three cards and creates an Eldrazi Spawn token" do
    p1.add_mana(blue: 5)
    hand_before = p1.hand.count

    p1.cast(card: card) { _1.pay_mana(generic: { blue: 4 }, blue: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.hand.count).to eq(hand_before + 3)
    expect(spawns.count).to eq(1)
    expect([spawns.first.power, spawns.first.toughness]).to eq([0, 1])
    expect(spawns.first.colors).to be_empty
  end
end
