# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrayMerchantOfAsphodel do
  include_context "two player game"

  it "drains each opponent for your devotion to black, counting itself" do
    ResolvePermanent("Blood Artist", owner: p1) # {1}{B}
    ResolvePermanent("Gray Merchant Of Asphodel", owner: p1) # {3}{B}{B}
    game.settle!

    expect(p2.life).to eq(17)
    expect(p1.life).to eq(23)
  end

  it "counts hybrid mana symbols towards both of their colours" do
    ResolvePermanent("Spiteful Visions", owner: p1) # {2}{B/R}{B/R}

    expect(p1.devotion(:black)).to eq(2)
    expect(p1.devotion(:red)).to eq(2)
    expect(p1.devotion(:white)).to eq(0)
  end

  it "counts only your permanents" do
    ResolvePermanent("Blood Artist", owner: p2)
    ResolvePermanent("Gray Merchant Of Asphodel", owner: p1)
    game.settle!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end

  it "doesn't gain life when life gain is prevented" do
    ResolvePermanent("Rampaging Ferocidon", owner: p2)
    ResolvePermanent("Gray Merchant Of Asphodel", owner: p1)
    game.settle!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(19) # one from the Ferocidon's damage
  end
end
