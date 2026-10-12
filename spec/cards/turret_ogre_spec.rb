# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TurretOgre do
  include_context "two player game"

  it "is a 4/3 Ogre Warrior with reach" do
    ogre = ResolvePermanent("Turret Ogre", owner: p1)

    expect([ogre.power, ogre.toughness]).to eq([4, 3])
    expect(ogre).to be_reach
  end

  it "deals 2 damage to each opponent if you control another creature with power 4 or greater" do
    ResolvePermanent("Serra Angel", owner: p1)
    ResolvePermanent("Turret Ogre", owner: p1)
    game.settle!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(20)
  end

  it "does nothing if your only creature with power 4 or greater is itself" do
    ResolvePermanent("Turret Ogre", owner: p1)
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "does not count a big creature an opponent controls" do
    ResolvePermanent("Serra Angel", owner: p2)
    ResolvePermanent("Turret Ogre", owner: p1)
    game.settle!

    expect(p2.life).to eq(20)
  end
end
