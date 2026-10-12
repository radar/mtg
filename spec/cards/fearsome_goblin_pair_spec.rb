# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearsomeGoblinPair do
  include_context "two player game"

  let!(:pair) { ResolvePermanent("Fearsome Goblin Pair", owner: p1) }

  def armies = p1.creatures.select { _1.type?("Army") }

  it "is a 1/1 Goblin Soldier" do
    expect(pair.power).to eq(1)
    expect(pair.toughness).to eq(1)
    expect(pair.type?("Goblin")).to eq(true)
  end

  it "amasses Goblins 4 when it dies, creating a Goblin Army if you have none" do
    pair.destroy!
    game.settle!
    game.tick!

    expect(armies.count).to eq(1)
    army = armies.first
    expect([army.power, army.toughness]).to eq([4, 4])
    expect(army.type?("Goblin")).to eq(true)
  end

  it "puts the counters on the existing Army instead of making another" do
    second = ResolvePermanent("Fearsome Goblin Pair", owner: p1)
    pair.destroy!
    game.settle!
    second.destroy!
    game.settle!
    game.tick!

    expect(armies.count).to eq(1)
    expect(armies.first.power).to eq(8)
  end
end
