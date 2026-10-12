# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DuskwatchHunter do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:hunter) { ResolvePermanent("Duskwatch Hunter", owner: p1) }

  it "is a 3/1 Wolf" do
    expect([hunter.power, hunter.toughness]).to eq([3, 1])
    expect(hunter.type?("Wolf")).to eq(true)
  end

  it "puts a +1/+1 counter on target creature when it enters" do
    game.resolve_choice!(target: bears)
    game.tick!
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "can't be blocked by tokens but can be blocked by nontoken creatures" do
    game.resolve_choice!(target: hunter)
    token = Magic::Amass::GoblinArmyToken.new(game: game, owner: p2, base_power: 2, base_toughness: 2).resolve!
    expect(token.token?).to eq(true)
    expect(hunter.can_be_blocked?(token)).to eq(false)
    expect(hunter.can_be_blocked?(bears)).to eq(true)
  end
end
