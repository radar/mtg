# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LuminousBroodmoth do
  include_context "two player game"

  let!(:broodmoth) { ResolvePermanent("Luminous Broodmoth", owner: p1) }

  it "is a 3/4 flyer" do
    expect([broodmoth.power, broodmoth.toughness]).to eq([3, 4])
    expect(broodmoth).to be_flying
  end

  it "returns a creature without flying that dies, with a flying counter" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.destroy!
    game.settle!
    game.tick!

    returned = p1.permanents.by_name("Grizzly Bears").first
    expect(returned).not_to be_nil
    expect(returned).to be_flying
    expect(returned.counters.map(&:class)).to include(Magic::Counters::Flying)
  end

  it "does not return a creature that has flying" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p1)
    angel.destroy!
    game.settle!

    expect(p1.permanents.by_name("Baneslayer Angel")).to be_empty
  end

  it "does not return an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    theirs.destroy!
    game.settle!

    expect(p2.permanents.by_name("Grizzly Bears")).to be_empty
  end

  it "returns a creature only once: it has flying now" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.destroy!
    game.settle!
    game.tick!
    p1.permanents.by_name("Grizzly Bears").first.destroy!
    game.settle!

    expect(p1.permanents.by_name("Grizzly Bears")).to be_empty
  end

  it "does nothing for a token" do
    token = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!
    token.destroy!

    expect { game.settle! }.not_to raise_error
    expect(p1.permanents.by_name("Goblin")).to be_empty
  end
end
