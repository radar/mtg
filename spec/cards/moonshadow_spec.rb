# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Moonshadow do
  include_context "two player game"

  let!(:moonshadow) { ResolvePermanent("Moonshadow", owner: p1) }

  def to_graveyard(name, player)
    card = Card(name, owner: player)
    player.hand.add(card)
    card.move_to_graveyard!(player)
  end

  def counters = moonshadow.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a menace Elemental that enters with six -1/-1 counters, so it is a 1/1" do
    game.tick!

    expect(moonshadow).to be_menace
    expect(counters).to eq(6)
    expect([moonshadow.power, moonshadow.toughness]).to eq([1, 1])
  end

  it "loses a counter when a permanent card is put into your graveyard" do
    to_graveyard("Grizzly Bears", p1)
    game.settle!

    expect(counters).to eq(5)
  end

  it "does not react to an instant going to your graveyard" do
    to_graveyard("Lightning Bolt", p1)
    game.settle!

    expect(counters).to eq(6)
  end

  it "does not react to the opponent's graveyard" do
    to_graveyard("Grizzly Bears", p2)
    game.settle!

    expect(counters).to eq(6)
  end

  it "loses only one counter when several permanent cards arrive together (one or more)" do
    p1.library.add(Card("Forest", owner: p1))
    p1.library.add(Card("Forest", owner: p1))
    p1.library.add(Card("Forest", owner: p1))
    p1.mill(3)
    game.settle!

    expect(counters).to eq(5)
  end

  it "loses a counter when your creature dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.destroy!
    game.settle!

    expect(counters).to eq(5)
  end
end
