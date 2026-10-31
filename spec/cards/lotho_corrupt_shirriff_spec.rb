# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LothoCorruptShirriff do
  include_context "two player game"

  let!(:lotho) { ResolvePermanent("Lotho Corrupt Shirriff", owner: p1) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def bolt(player, target)
    card = Card("Lightning Bolt", owner: player)
    player.hand.add(card)
    player.add_mana(red: 1)
    player.cast(card:) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "does nothing on a player's first spell" do
    bolt(p1, p2)

    expect(treasures).to be_empty
    expect(p1.life).to eq(20)
  end

  it "makes you lose 1 life and create a Treasure when you cast your second spell" do
    bolt(p1, p2)
    bolt(p1, p2)

    expect(treasures.count).to eq(1)
    expect(p1.life).to eq(19)
  end

  it "triggers for an opponent's second spell, still affecting you" do
    bolt(p2, p2)
    bolt(p2, p2)

    expect(treasures.count).to eq(1)
    expect(p1.life).to eq(19)
  end

  it "counts each player's spells separately" do
    bolt(p1, p2)
    bolt(p2, p1)

    expect(treasures).to be_empty
  end

  it "does not trigger on a third spell" do
    3.times { bolt(p1, p2) }

    expect(treasures.count).to eq(1)
  end
end
