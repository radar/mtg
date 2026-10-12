# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GraspingLongneck do
  include_context "two player game"

  it "is a 4/2 reach enchantment creature" do
    longneck = ResolvePermanent("Grasping Longneck", owner: p1)

    expect([longneck.power, longneck.toughness]).to eq([4, 2])
    expect(longneck).to be_reach
    expect(longneck.type?("Enchantment")).to be(true)
  end

  it "gains its controller 2 life when it dies" do
    longneck = ResolvePermanent("Grasping Longneck", owner: p1)
    life = p1.life
    longneck.destroy!
    game.settle!

    expect(p1.life).to eq(life + 2)
  end
end
