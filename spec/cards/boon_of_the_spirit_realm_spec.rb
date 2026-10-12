require "spec_helper"

RSpec.describe Magic::Cards::BoonOfTheSpiritRealm do
  include_context "two player game"

  it "adds a blessing counter when an enchantment enters" do
    boon = ResolvePermanent("Boon of The Spirit Realm", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(boon.counters.count).to eq(2)
  end

  it "gives creatures +1/+1 for each blessing counter" do
    ResolvePermanent("Boon of The Spirit Realm", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "works out a power and toughness when Starfield of Nyx makes it a creature" do
    boon = ResolvePermanent("Boon of The Spirit Realm", owner: p1)
    4.times { ResolvePermanent("Phyrexian Arena", owner: p1) }
    ResolvePermanent("Starfield of Nyx", owner: p1)
    game.tick!

    expect(boon).to be_creature
    # Base 5 (its mana value), and +1/+1 for each of its six blessing counters (one for each enchantment that entered),
    # since it is now a creature you control. The counters themselves add nothing of their own.
    expect([boon.power, boon.toughness]).to eq([11, 11])
  end
end