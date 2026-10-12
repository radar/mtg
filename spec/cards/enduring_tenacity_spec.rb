# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnduringTenacity do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:tenacity) { ResolvePermanent("Enduring Tenacity", owner: p1) }

  it "is a 4/3 Enchantment Creature — Snake Glimmer" do
    expect([tenacity.power, tenacity.toughness]).to eq([4, 3])
    expect(tenacity.type?("Enchantment")).to be(true)
    expect(tenacity.creature?).to be(true)
  end

  it "makes an opponent lose that much life when you gain life" do
    expect do
      p1.gain_life(3)
      game.settle!
    end.to change { p2.life }.by(-3)
  end

  it "does not trigger when an opponent gains life" do
    p2.gain_life(3)
    game.settle!

    expect([p1.life, p2.life]).to eq([20, 23])
  end

  it "returns as a non-creature enchantment when it dies as a creature" do
    tenacity.destroy!
    game.settle!

    returned = game.battlefield.cards.by_name("Enduring Tenacity").first
    expect(returned).not_to be_nil
    expect(returned.creature?).to be(false)
    expect(returned.type?("Enchantment")).to be(true)
  end

  it "stays dead the second time it would die as a non-creature" do
    tenacity.destroy!
    game.settle!
    returned = game.battlefield.cards.by_name("Enduring Tenacity").first
    returned.destroy!
    game.settle!

    expect(game.battlefield.cards.map(&:name)).not_to include("Enduring Tenacity")
    expect(p1.graveyard.cards.map(&:name)).to include("Enduring Tenacity")
  end
end
