# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NadiersNightblade do
  include_context "two player game"

  let!(:blade) { ResolvePermanent("Nadier's Nightblade", owner: p1) }

  def token_for(player) = Magic::Tokens::HumanSoldier.new(game: game, owner: player).resolve!

  it "is a 1/3 Elf Warrior" do
    expect([blade.power, blade.toughness]).to eq([1, 3])
    expect(blade.type?("Elf")).to eq(true)
  end

  it "drains each opponent when a token you control leaves" do
    token = token_for(p1)
    game.settle!
    token.sacrifice!
    game.settle!
    game.stack.resolve!
    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "ignores a token an opponent controls" do
    token = token_for(p2)
    game.settle!
    token.sacrifice!
    game.settle!
    game.stack.resolve!
    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end

  it "ignores a nontoken permanent you control" do
    elves = ResolvePermanent("Llanowar Elves", owner: p1)
    elves.sacrifice!
    game.settle!
    game.stack.resolve!
    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end
end
