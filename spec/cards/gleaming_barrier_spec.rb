# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GleamingBarrier do
  include_context "two player game"

  let!(:barrier) { ResolvePermanent("Gleaming Barrier", owner: p1) }

  it "is a 0/4 Wall artifact creature with defender" do
    expect([barrier.power, barrier.toughness]).to eq([0, 4])
    expect(barrier).to be_defender
  end

  it "creates a Treasure token when it dies" do
    barrier.destroy!
    game.settle!

    expect(p1.permanents.by_name("Treasure").count).to eq(1)
  end
end
