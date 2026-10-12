# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheWanderingRescuer do
  include_context "two player game"

  let!(:rescuer) { ResolvePermanent("The Wandering Rescuer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 3/4 legendary flash, convoke, double strike creature" do
    expect([rescuer.power, rescuer.toughness]).to eq([3, 4])
    expect(rescuer).to have_keyword(:double_strike)
    expect(rescuer.card.convoke?).to be(true)
    expect(rescuer.card.flash?).to be(true)
  end

  it "gives other tapped creatures you control hexproof" do
    bears.tap!
    game.tick!

    expect(bears).to have_keyword(:hexproof)
  end

  it "does not give hexproof to untapped creatures" do
    game.tick!

    expect(bears).not_to have_keyword(:hexproof)
  end

  it "does not give hexproof to itself when tapped" do
    rescuer.tap!
    game.tick!

    expect(rescuer).not_to have_keyword(:hexproof)
  end

  it "does not give hexproof to opponents' tapped creatures" do
    opp_bears.tap!
    game.tick!

    expect(opp_bears).not_to have_keyword(:hexproof)
  end
end
