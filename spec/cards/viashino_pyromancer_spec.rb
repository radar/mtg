# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ViashinoPyromancer do
  include_context "two player game"

  it "is a 2/1 Lizard Wizard" do
    pyromancer = ResolvePermanent("Viashino Pyromancer", owner: p1, settle: false)

    expect([pyromancer.power, pyromancer.toughness]).to eq([2, 1])
  end

  it "deals 2 damage to a target player when it enters" do
    ResolvePermanent("Viashino Pyromancer", owner: p1)
    game.settle!
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(20)
  end

  it "can target its controller" do
    ResolvePermanent("Viashino Pyromancer", owner: p1)
    game.settle!
    game.resolve_choice!(target: p1)

    expect(p1.life).to eq(18)
  end

  it "cannot target creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Viashino Pyromancer", owner: p1)
    game.settle!

    expect(game.choices.first.choices).to contain_exactly(p1, p2)
    expect(bears.damage).to eq(0)
  end
end
