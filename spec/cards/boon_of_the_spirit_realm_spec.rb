require "spec_helper"

RSpec.describe Magic::Cards::BoonOfTheSpiritRealm do
  include_context "two player game"

  it "adds a blessing counter when an enchantment enters" do
    boon = ResolvePermanent("Boon of The Spirit Realm", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(boon.counters.count).to eq(2)
  end
end