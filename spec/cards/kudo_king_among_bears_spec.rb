# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KudoKingAmongBears do
  include_context "two player game"

  let!(:kudo) { ResolvePermanent("Kudo, King Among Bears", owner: p1) }

  it "is a legendary 2/2 Bear" do
    expect([kudo.power, kudo.toughness]).to eq([2, 2])
    expect(kudo.type?("Bear")).to eq(true)
    expect(kudo.legendary?).to eq(true)
  end

  it "makes other creatures 2/2 Bears, including opponents' creatures" do
    mine = ResolvePermanent("Llanowar Elves", owner: p1)
    theirs = ResolvePermanent("Llanowar Elves", owner: p2)
    game.tick!
    [mine, theirs].each do |creature|
      expect([creature.power, creature.toughness]).to eq([2, 2])
      expect(creature.type?("Bear")).to eq(true)
      expect(creature.type?("Elf")).to eq(true)
    end
  end

  it "makes tokens 2/2 Bears as well" do
    token = Magic::Tokens::HumanSoldier.new(game: game, owner: p2).resolve!
    game.tick!
    expect(token.type?("Bear")).to eq(true)
    expect([token.power, token.toughness]).to eq([2, 2])
  end

  it "keeps counters on top of the base 2/2" do
    elves = ResolvePermanent("Llanowar Elves", owner: p1)
    elves.add_counter("+1/+1", amount: 2)
    game.tick!
    expect([elves.power, elves.toughness]).to eq([4, 4])
  end

  it "stops applying when Kudo leaves the battlefield" do
    elves = ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!
    kudo.destroy!
    game.settle!
    game.tick!
    expect([elves.power, elves.toughness]).to eq([1, 1])
    expect(elves.type?("Bear")).to eq(false)
  end
end
