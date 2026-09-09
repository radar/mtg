require "spec_helper"

RSpec.describe Magic::Cards::SetessanChampion do
  include_context "two player game"

  it "gets a counter and draws when an enchantment enters" do
    champion = ResolvePermanent("Setessan Champion", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(champion.counters.count).to eq(1)
  end
end