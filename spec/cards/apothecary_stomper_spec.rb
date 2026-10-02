# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ApothecaryStomper do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:stomper) { ResolvePermanent("Apothecary Stomper", owner: p1) }

  it "is a 4/4 Elephant with vigilance" do
    expect([stomper.power, stomper.toughness]).to eq([4, 4])
    expect(stomper).to be_vigilant
  end

  it "puts two +1/+1 counters on target creature you control" do
    game.resolve_choice!(mode: 0)
    game.resolve_choice!(target: bears)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "gains 4 life" do
    game.resolve_choice!(mode: 1)

    expect(p1.life).to eq(24)
  end
end
