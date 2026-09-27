# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WanderwineDistracter do
  include_context "two player game"

  let!(:distracter) { ResolvePermanent("Wanderwine Distracter", owner: p1) }

  it "is a 4/3 merfolk wizard" do
    expect(distracter.card.types).to include("Merfolk", "Wizard")
    expect(distracter.power).to eq(4)
    expect(distracter.toughness).to eq(3)
  end

  it "gives target creature an opponent controls -3/-0 until end of turn when it becomes tapped" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    distracter.tap!
    game.settle! # only one legal target, so it auto-resolves

    expect(bears.power).to eq(-1)
    expect(bears.toughness).to eq(2)
  end
end
