require "spec_helper"

RSpec.describe Magic::Cards::FortifiedVillage do
  include_context "two player game"

  it "enters untapped with a Forest in hand" do
    village = ResolvePermanent("Fortified Village", owner: p1)

    expect(village).to be_untapped
  end
end