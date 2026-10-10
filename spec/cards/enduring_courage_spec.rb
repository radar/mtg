# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnduringCourage do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:courage) { ResolvePermanent("Enduring Courage", owner: p1) }

  it "is a 3/3 Enchantment Creature — Dog Glimmer" do
    expect([courage.power, courage.toughness]).to eq([3, 3])
    expect(courage.type?("Enchantment")).to be(true)
  end

  it "gives another creature you control +2/+0 and haste when it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 2])
    expect(bears.haste?).to be(true)
  end

  it "does not affect creatures an opponent controls" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!
    game.tick!

    expect(bears.power).to eq(2)
  end

  it "does not buff itself" do
    expect(courage.power).to eq(3)
  end

  it "returns as a non-creature enchantment when it dies" do
    courage.destroy!
    game.settle!

    returned = game.battlefield.cards.by_name("Enduring Courage").first
    expect(returned.creature?).to be(false)
    expect(returned.type?("Enchantment")).to be(true)
  end
end
