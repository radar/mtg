# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeathbloomThallid do
  include_context "two player game"

  let!(:thallid) { ResolvePermanent("Deathbloom Thallid", owner: p1) }

  it "is a 3/2 Fungus" do
    expect([thallid.power, thallid.toughness]).to eq([3, 2])
  end

  it "creates a 1/1 green Saproling when it dies" do
    thallid.destroy!
    game.settle!

    saproling = p1.creatures.by_name("Saproling").first
    expect([saproling.power, saproling.toughness]).to eq([1, 1])
    expect(saproling.colors).to eq([:green])
  end
end
