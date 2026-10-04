# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PoisonTipArcher do
  include_context "two player game"

  let!(:archer) { ResolvePermanent("Poison-Tip Archer", owner: p1) }

  it "has reach and deathtouch" do
    expect(archer.reach?).to eq(true)
    expect(archer.deathtouch?).to eq(true)
  end

  it "makes each opponent lose 1 life when another creature you control dies" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "makes each opponent lose 1 life when an opponent's creature dies" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "does not trigger on its own death" do
    archer.destroy!
    game.settle!

    expect(p2.life).to eq(20)
  end
end
