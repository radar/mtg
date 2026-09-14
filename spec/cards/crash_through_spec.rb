# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CrashThrough do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:opponent_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  let(:crash_through) { Card("Crash Through", owner: p1) }

  before do
    p1.hand.add(crash_through)
    p1.add_mana(red: 1)
  end

  it "gives creatures you control trample until end of turn" do
    cast_and_resolve(card: crash_through, player: p1) { |a| a.pay_mana(red: 1) }
    game.tick!

    expect(wood_elves).to be_trample
  end

  it "does not give trample to creatures you don't control" do
    cast_and_resolve(card: crash_through, player: p1) { |a| a.pay_mana(red: 1) }
    game.tick!

    expect(opponent_elves.trample?).to eq(false)
  end

  it "makes the player draw a card" do
    expect(p1).to receive(:draw!)
    cast_and_resolve(card: crash_through, player: p1) { |a| a.pay_mana(red: 1) }
  end

  it "moves the card to the graveyard after resolving" do
    cast_and_resolve(card: crash_through, player: p1) { |a| a.pay_mana(red: 1) }

    expect(crash_through.zone).to be_graveyard
  end
end
