# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnigmaDrake do
  include_context "two player game"

  let!(:drake) { ResolvePermanent("Enigma Drake", owner: p1) }

  def add_to_graveyard(player, name)
    player.graveyard.add(Card(name, owner: player))
    game.tick!
  end

  it "is a flying */4 Drake, 0/4 with an empty graveyard" do
    expect([drake.power, drake.toughness]).to eq([0, 4])
    expect(drake.has_keyword?(:flying)).to eq(true)
  end

  it "has power equal to the number of instant and sorcery cards in your graveyard" do
    add_to_graveyard(p1, "Boltwave")
    add_to_graveyard(p1, "Zombify")
    add_to_graveyard(p1, "Boltwave")

    expect(drake.power).to eq(3)
    expect(drake.toughness).to eq(4)
  end

  it "doesn't count creatures or the opponent's graveyard" do
    add_to_graveyard(p1, "Boltwave")
    add_to_graveyard(p1, "Grizzly Bears")
    add_to_graveyard(p2, "Boltwave")

    expect(drake.power).to eq(1)
  end
end
