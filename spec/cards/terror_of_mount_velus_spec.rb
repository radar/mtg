# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TerrorOfMountVelus do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:terror) { ResolvePermanent("Terror Of Mount Velus", owner: p1) }

  before { game.tick! }

  it "is a 5/5 flying double striker" do
    expect([terror.power, terror.toughness]).to eq([5, 5])
    expect(terror).to be_flying
    expect(terror).to be_double_strike
  end

  it "gives creatures you control double strike until end of turn when it enters" do
    expect(bears).to be_double_strike
    expect(rival).not_to be_double_strike
  end

  it "wears off at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears).not_to be_double_strike
  end
end
