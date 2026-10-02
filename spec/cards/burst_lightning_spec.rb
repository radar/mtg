# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurstLightning do
  include_context "two player game"

  it "deals 2 damage to any target" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Burst Lightning", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(18)
  end

  it "deals 4 damage when kicked" do
    p1.add_mana(red: 5)
    p1.cast(card: Card("Burst Lightning", owner: p1)) { |a| a.pay_mana(red: 1).pay_kicker(generic: { red: 4 }).targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(16)
  end

  it "can kill a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 1)
    p1.cast(card: Card("Burst Lightning", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect(bears.card.zone).to be_graveyard
  end
end
