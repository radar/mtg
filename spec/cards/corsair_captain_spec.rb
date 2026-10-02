# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CorsairCaptain do
  include_context "two player game"

  let!(:captain) { ResolvePermanent("Corsair Captain", owner: p1) }
  let!(:pirate) { ResolvePermanent("Bigfin Bouncer", owner: p1) } # Shark Pirate
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { game.tick! }

  it "creates a Treasure token when it enters" do
    expect(p1.permanents.by_name("Treasure").count).to eq(1)
  end

  it "gives other Pirates you control +1/+1" do
    expect([pirate.power, pirate.toughness]).to eq([4, 3])
  end

  it "doesn't buff itself or non-Pirates" do
    expect([captain.power, captain.toughness]).to eq([2, 2])
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end
end
