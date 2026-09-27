# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoneclubBerserker do
  include_context "two player game"

  let!(:berserker) { ResolvePermanent("Boneclub Berserker", owner: p1) }

  it "is a 2/4 goblin berserker" do
    expect(berserker.card.types).to include("Goblin", "Berserker")
    expect(berserker.power).to eq(2)
    expect(berserker.toughness).to eq(4)
  end

  it "gets +2/+0 for each other Goblin its controller controls" do
    ResolvePermanent("Bile-Vial Boggart", owner: p1)
    game.tick!

    expect(berserker.power).to eq(4)
  end

  it "doesn't count itself or an opponent's Goblin" do
    ResolvePermanent("Bile-Vial Boggart", owner: p2)
    game.tick!

    expect(berserker.power).to eq(2)
  end
end
