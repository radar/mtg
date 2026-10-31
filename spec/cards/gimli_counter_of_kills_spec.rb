# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GimliCounterOfKills do
  include_context "two player game"

  let!(:gimli) { ResolvePermanent("Gimli, Counter Of Kills", owner: p1) }

  it "is a 4/3 legendary Dwarf Warrior with trample" do
    expect([gimli.power, gimli.toughness]).to eq([4, 3])
    expect(gimli).to be_trample
  end

  it "deals 1 damage to the controller of a creature an opponent controls that dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.destroy!
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "triggers once for each creature that dies" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "doesn't trigger for creatures you control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.destroy!
    game.settle!

    expect(p1.life).to eq(20)
    expect(p2.life).to eq(20)
  end

  it "doesn't trigger when Gimli itself dies" do
    gimli.destroy!
    game.settle!

    expect(p1.life).to eq(20)
    expect(p2.life).to eq(20)
  end
end
