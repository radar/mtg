# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LakeshoreApothecary do
  include_context "two player game"

  let!(:apothecary) { ResolvePermanent("Lakeshore Apothecary", owner: p1) }

  it "is a 1/2 with vigilance" do
    expect(apothecary.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
    expect(apothecary.power).to eq(1)
    expect(apothecary.toughness).to eq(2)
  end

  it "gets a +1/+1 counter when you draw your second card each turn" do
    p1.draw!
    game.settle!
    expect(apothecary.power).to eq(1)
    p1.draw!
    game.settle!
    expect(apothecary.power).to eq(2)
    expect(apothecary.toughness).to eq(3)
  end
end
