# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GadrakTheCrownScourge do
  include_context "two player game"

  let!(:gadrak) { ResolvePermanent("Gadrak, The Crown-Scourge", owner: p1) }

  def treasures = p1.permanents.by_name("Treasure")

  it "is a 5/4 flying Dragon" do
    expect([gadrak.power, gadrak.toughness]).to eq([5, 4])
    expect(gadrak).to be_flying
  end

  it "can't attack unless you control four or more artifacts" do
    expect(gadrak.can_attack?).to eq(false)

    3.times { ResolvePermanent("Sol Ring", owner: p1) }
    expect(gadrak.can_attack?).to eq(false)

    ResolvePermanent("Sol Ring", owner: p1)
    expect(gadrak.can_attack?).to eq(true)
  end

  it "creates a Treasure for each nontoken creature that died this turn at your end step" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    current_turn.end!
    game.settle!

    expect(treasures.count).to eq(2)
  end

  it "doesn't count tokens" do
    token = ResolvePermanent("Grizzly Bears", owner: p1)
    allow(token).to receive(:token?).and_return(true)
    token.destroy!
    game.settle!
    current_turn.end!
    game.settle!

    expect(treasures.count).to eq(0)
  end

  it "creates nothing at an opponent's end step" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    game.next_turn
    current_turn.end!
    game.settle!

    expect(treasures.count).to eq(0)
  end
end
