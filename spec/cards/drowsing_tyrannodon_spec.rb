# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DrowsingTyrannodon do
  include_context "two player game"

  let!(:tyrannodon) { ResolvePermanent("Drowsing Tyrannodon", owner: p1) }

  it "is a 3/3 Dinosaur with defender that can't attack alone" do
    expect([tyrannodon.power, tyrannodon.toughness]).to eq([3, 3])
    expect(tyrannodon.can_attack?).to eq(false)
  end

  it "can attack while you control a creature with power 4 or greater" do
    ResolvePermanent("Garruks Gorehorn", owner: p1)
    game.tick!

    expect(tyrannodon.can_attack?).to eq(true)
  end

  it "ignores a big creature an opponent controls" do
    ResolvePermanent("Garruks Gorehorn", owner: p2)
    game.tick!

    expect(tyrannodon.can_attack?).to eq(false)
  end

  it "ignores a creature with power below 4" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(tyrannodon.can_attack?).to eq(false)
  end
end
