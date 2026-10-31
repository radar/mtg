# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LobeliaSackvilleBaggins do
  include_context "two player game"

  before { go_to_main_phase! }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def cast_lobelia
    card = Card("Lobelia Sackville-Baggins", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!
    card
  end

  def die(player, name = "Grizzly Bears")
    perm = ResolvePermanent(name, owner: player)
    card = perm.card
    perm.destroy!
    game.settle!
    card
  end

  it "has flash and menace and is 2/3" do
    lobelia = ResolvePermanent("Lobelia Sackville-Baggins", owner: p1)

    expect(lobelia).to have_keyword(:flash)
    expect(lobelia).to have_keyword(:menace)
    expect([lobelia.power, lobelia.toughness]).to eq([2, 3])
  end

  it "exiles an opponent's creature card that died this turn and creates Treasures equal to its power" do
    dead = die(p2)
    cast_lobelia

    expect(dead.zone).to be_exile
    expect(treasures.count).to eq(2)
  end

  it "lets you choose among several valid cards" do
    bears = die(p2)
    ogre = die(p2, "Large Bear")
    cast_lobelia
    game.resolve_choice!(target: ogre)
    game.settle!

    expect(ogre.zone).to be_exile
    expect(bears.zone).to be_graveyard
    expect(treasures.count).to eq(5)
  end

  it "does nothing when the opponent's creature card was not put there this turn" do
    old = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(old)
    cast_lobelia

    expect(old.zone).to be_graveyard
    expect(treasures).to be_empty
  end

  it "does nothing for a card put into the graveyard from elsewhere this turn" do
    discarded = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(discarded)
    die(p1)
    cast_lobelia

    expect(discarded.zone).to be_graveyard
    expect(treasures).to be_empty
  end

  it "can't take your own graveyard's creature" do
    mine = die(p1)
    cast_lobelia

    expect(mine.zone).to be_graveyard
    expect(treasures).to be_empty
  end
end
