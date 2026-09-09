require "spec_helper"

RSpec.describe Magic::Cards::DemonOfFatesDesign do
  include_context "two player game"

  it "is an enchantment creature with flying and trample" do
    demon = ResolvePermanent("Demon of Fate's Design", owner: p1)

    expect(demon).to be_creature
    expect(demon).to be_enchantment
    expect(demon).to be_flying
    expect(demon).to be_trample
  end
end