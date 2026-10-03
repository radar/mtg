# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinNegotiation do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) } # 2/2

  def cast(target, x:)
    card = Card("Goblin Negotiation", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: x + 2)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { red: x }, red: 2).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  def goblins = p1.creatures.select { _1.name == "Goblin" }

  it "deals X damage to the creature" do
    big = ResolvePermanent("Baneslayer Angel", owner: p2) # 5/5
    cast(big, x: 3)

    expect(big.damage).to eq(3)
    expect(goblins).to be_empty
  end

  it "creates a 1/1 red Goblin for each point of damage beyond lethal" do
    cast(bears, x: 5)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(goblins.size).to eq(3)
    expect(goblins.map { [_1.power, _1.toughness] }.uniq).to eq([[1, 1]])
    expect(goblins.first.colors).to eq([:red])
  end

  it "creates no Goblins when the damage is exactly lethal" do
    cast(bears, x: 2)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(goblins).to be_empty
  end

  it "counts only damage beyond what was left to lethal on an already damaged creature" do
    cast(bears, x: 1)
    expect(goblins).to be_empty

    cast(bears, x: 3) # 1 was lethal, so 2 excess

    expect(goblins.size).to eq(2)
  end

  it "makes no Goblins with X = 0" do
    cast(bears, x: 0)

    expect(goblins).to be_empty
    expect(bears.damage).to eq(0)
  end

  it "can target your own creature, and the Goblins are still yours" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    cast(mine, x: 4)

    expect(goblins.size).to eq(2)
  end
end
