require "spec_helper"

RSpec.describe Magic::Cards::CacophonyUnleashed do
  include_context "two player game"

  it "destroys nonenchantment creatures when cast" do
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Cacophony Unleashed", owner: p1)
    game.stack.resolve!

    expect(p2.graveyard.by_name(creature.name).count).to eq(1)
  end

  it "becomes a legendary 6/6 Nightmare God with menace and deathtouch" do
    permanent = ResolvePermanent("Cacophony Unleashed", owner: p1)
    game.stack.resolve!
    game.tick!

    expect(permanent).to be_creature
    expect(permanent).to be_enchantment
    expect(permanent).to be_legendary
    expect(permanent.power).to eq(6)
    expect(permanent.toughness).to eq(6)
    expect(permanent.has_keyword?(:menace)).to be(true)
    expect(permanent.has_keyword?(:deathtouch)).to be(true)
  end

  it "becomes a creature when another enchantment enters under your control" do
    permanent = ResolvePermanent("Cacophony Unleashed", owner: p1)
    game.stack.resolve!
    ResolvePermanent("Phyrexian Arena", owner: p1)
    game.stack.resolve!
    game.tick!

    expect(permanent).to be_creature
    expect(permanent.power).to eq(6)
  end
end