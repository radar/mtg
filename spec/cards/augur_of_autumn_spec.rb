require "spec_helper"

RSpec.describe Magic::Cards::AugurOfAutumn do
  include_context "two player game"

  it "reveals the top card and allows a top land to be played" do
    ResolvePermanent("Augur of Autumn", owner: p1)
    top_land = p1.library.first

    expect(top_land).to be_revealed
    p1.play_land(land: top_land)

    expect(p1.lands.by_name(top_land.name).count).to eq(1)
  end

  it "allows a top creature to be cast with coven" do
    ResolvePermanent("Augur of Autumn", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Alpine Grizzly", owner: p1)
    ResolvePermanent("Raging Goblin", owner: p1)
    creature = Card("Grizzly Bears", owner: p1)
    p1.library.add(creature, 0)
    p1.add_mana(generic: 1, green: 1)

    action = p1.prepare_cast(card: creature)
    expect(action.can_perform?).to be(true)
  end
end