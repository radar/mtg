# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NastyLittleRabbit do
  include_context "two player game"

  let!(:rabbit) { ResolvePermanent("Nasty Little Rabbit", owner: p1) }

  it "is a 1/2 Rabbit" do
    expect([rabbit.power, rabbit.toughness]).to eq([1, 2])
  end

  it "grows at the beginning of combat if you control a creature with power 4 or greater" do
    ResolvePermanent("Ordinary Bear", owner: p1)
    skip_to_combat!
    game.settle!

    expect([rabbit.power, rabbit.toughness]).to eq([2, 3])
  end

  it "doesn't grow without a creature with power 4 or greater" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    game.settle!

    expect([rabbit.power, rabbit.toughness]).to eq([1, 2])
  end

  it "doesn't grow on an opponent's turn" do
    ResolvePermanent("Ordinary Bear", owner: p1)
    go_to_main_phase_for!(p2)
    skip_to_combat!
    game.settle!

    expect([rabbit.power, rabbit.toughness]).to eq([1, 2])
  end
end
