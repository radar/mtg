require "spec_helper"

RSpec.describe Magic::Cards::OmnathLocusOfRage do
  include_context "two player game"

  it "creates an Elemental when a land enters" do
    ResolvePermanent("Omnath, Locus Of Rage", owner: p1)
    ResolvePermanent("Forest", owner: p1)

    expect(p1.creatures.by_name("Elemental").count).to eq(1)
  end
end