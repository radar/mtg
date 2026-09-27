# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlamekinGildweaver do
  include_context "two player game"

  it "is a 4/3 elemental sorcerer with trample" do
    gildweaver = ResolvePermanent("Flamekin Gildweaver", owner: p1)

    expect(gildweaver.card.types).to include("Elemental", "Sorcerer")
    expect(gildweaver.power).to eq(4)
    expect(gildweaver.toughness).to eq(3)
    expect(gildweaver.trample?).to be(true)
  end

  it "creates a Treasure token when it enters" do
    ResolvePermanent("Flamekin Gildweaver", owner: p1)

    expect(p1.permanents.select { |permanent| permanent.name == "Treasure" }.count).to eq(1)
  end
end
