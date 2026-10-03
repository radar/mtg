# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GhituLavarunner do
  include_context "two player game"

  let!(:lavarunner) { ResolvePermanent("Ghitu Lavarunner", owner: p1) }

  def add_to_graveyard(player, name)
    player.graveyard.add(Card(name, owner: player))
    game.tick!
  end

  it "is a 1/2 Human Wizard without haste" do
    expect([lavarunner.power, lavarunner.toughness]).to eq([1, 2])
    expect(lavarunner.has_keyword?(:haste)).to eq(false)
  end

  it "stays 1/2 with one instant or sorcery in your graveyard" do
    add_to_graveyard(p1, "Boltwave")

    expect(lavarunner.power).to eq(1)
    expect(lavarunner.has_keyword?(:haste)).to eq(false)
  end

  it "gets +1/+0 and haste with two instant and/or sorcery cards in your graveyard" do
    add_to_graveyard(p1, "Boltwave")
    add_to_graveyard(p1, "Zombify")

    expect(lavarunner.power).to eq(2)
    expect(lavarunner.toughness).to eq(2)
    expect(lavarunner.has_keyword?(:haste)).to eq(true)
  end

  it "doesn't count other card types or the opponent's graveyard" do
    add_to_graveyard(p1, "Boltwave")
    add_to_graveyard(p1, "Grizzly Bears")
    add_to_graveyard(p2, "Boltwave")

    expect(lavarunner.power).to eq(1)
    expect(lavarunner.has_keyword?(:haste)).to eq(false)
  end
end
