# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PiggyBank do
  include_context "two player game"

  let!(:piggy) { ResolvePermanent("Piggy Bank", owner: p1) }

  it "is a 3/2 artifact creature" do
    expect([piggy.power, piggy.toughness]).to eq([3, 2])
    expect(piggy).to be_artifact
  end

  it "creates a Treasure when it dies" do
    piggy.destroy!
    game.settle!

    expect(p1.permanents.count { _1.name == "Treasure" }).to eq(1)
  end
end
