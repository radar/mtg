# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AzogMoriasRuin do
  include_context "two player game"

  def armies(player) = player.creatures.select { _1.type?("Army") }

  it "is a 1/3 legendary Goblin Soldier" do
    azog = ResolvePermanent("Azog, Moria's Ruin", owner: p1)

    expect([azog.power, azog.toughness]).to eq([1, 3])
    expect(azog.card.types).to include("Goblin", "Soldier")
  end

  it "destroys an opponent's creature, whose controller amasses Goblins equal to its power" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Azog, Moria's Ruin", owner: p1)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(armies(p2).size).to eq(1)
    expect(armies(p2).first.power).to eq(2)
    expect(armies(p2).first.type?("Goblin")).to be(true)
  end

  it "doesn't draw a card when the creature wasn't yours" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    hand = p1.hand.count
    ResolvePermanent("Azog, Moria's Ruin", owner: p1)
    game.resolve_choice!(target: bears)

    expect(p1.hand.count).to eq(hand)
  end

  it "draws a card and gives you the Army when it destroys your own creature" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    hand = p1.hand.count
    ResolvePermanent("Azog, Moria's Ruin", owner: p1)
    game.resolve_choice!(target: mine)
    game.tick!

    expect(p1.hand.count).to eq(hand + 1)
    expect(armies(p1).first.power).to eq(2)
  end

  it "may choose no target" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Azog, Moria's Ruin", owner: p1)
    game.skip_choice!

    expect(bears.zone).to be_battlefield
  end
end
