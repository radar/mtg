require "spec_helper"

RSpec.describe Magic::Cards::AniktheaHandOfErebos do
  include_context "two player game"

  it "copies a non-Aura enchantment from the graveyard when it enters" do
    source = Card("Phyrexian Arena", owner: p1)
    p1.graveyard.add(source)
    anikthea = ResolvePermanent("Anikthea, Hand of Erebos", owner: p1)

    game.resolve_choice!(target: source)

    copies = game.battlefield.by_name("Phyrexian Arena")
    expect(copies.count).to eq(1)
    expect(anikthea).to be_legendary
  end

  it "makes the copy a 3/3 black Zombie creature that lasts" do
    source = Card("Phyrexian Arena", owner: p1)
    p1.graveyard.add(source)
    ResolvePermanent("Anikthea, Hand of Erebos", owner: p1)
    game.resolve_choice!(target: source)

    copy = game.battlefield.by_name("Phyrexian Arena").first
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(copy).to be_creature
    expect(copy).to be_enchantment
    expect([copy.power, copy.toughness]).to eq([3, 3])
    expect(copy.colors).to eq([:black])
  end

  it "exiles the card from the graveyard" do
    source = Card("Phyrexian Arena", owner: p1)
    p1.graveyard.add(source)
    ResolvePermanent("Anikthea, Hand of Erebos", owner: p1)
    game.resolve_choice!(target: source)

    expect(p1.graveyard.cards).not_to include(source)
    expect(game.exile.cards).to include(source)
  end

  it "may take no card" do
    source = Card("Phyrexian Arena", owner: p1)
    p1.graveyard.add(source)
    ResolvePermanent("Anikthea, Hand of Erebos", owner: p1)
    game.resolve_choice!(target: nil)

    expect(game.battlefield.by_name("Phyrexian Arena").count).to eq(0)
  end

  it "is a 4/4" do
    anikthea = ResolvePermanent("Anikthea, Hand of Erebos", owner: p1)

    expect([anikthea.power, anikthea.toughness]).to eq([4, 4])
  end
end