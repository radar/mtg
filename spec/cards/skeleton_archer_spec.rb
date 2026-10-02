# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkeletonArcher do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 3/3 Skeleton Archer" do
    archer = ResolvePermanent("Skeleton Archer", owner: p1)

    expect([archer.power, archer.toughness]).to eq([3, 3])
  end

  it "deals 1 damage to any target when it enters (a player)" do
    ResolvePermanent("Skeleton Archer", owner: p1)
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(19)
  end

  it "deals 1 damage to any target when it enters (a creature)" do
    ResolvePermanent("Skeleton Archer", owner: p1)
    game.resolve_choice!(target: rival)

    expect(rival.damage).to eq(1)
  end
end
