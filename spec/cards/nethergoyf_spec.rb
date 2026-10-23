# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Nethergoyf do
  include_context "two player game"

  let(:card) { Card("Nethergoyf", owner: p1) }

  before { go_to_main_phase! }

  def bury(*names)
    names.map { |name| Card(name, owner: p1).tap { p1.graveyard.add(_1) } }
  end

  it "is 0/1 with an empty graveyard" do
    goyf = ResolvePermanent("Nethergoyf", owner: p1)
    game.tick!

    expect([goyf.power, goyf.toughness]).to eq([0, 1])
  end

  it "counts the card types among cards in its controller's graveyard" do
    goyf = ResolvePermanent("Nethergoyf", owner: p1)
    bury("Grizzly Bears", "Forest", "Lightning Bolt")
    game.tick!

    expect([goyf.power, goyf.toughness]).to eq([3, 4])
  end

  it "counts Kindred as a card type" do
    goyf = ResolvePermanent("Nethergoyf", owner: p1)
    bury("Grizzly Bears", "Crib Swap")
    game.tick!

    expect([goyf.power, goyf.toughness]).to eq([3, 4])
  end

  it "counts a type once" do
    goyf = ResolvePermanent("Nethergoyf", owner: p1)
    bury("Grizzly Bears", "Colossal Dreadmaw")
    game.tick!

    expect([goyf.power, goyf.toughness]).to eq([1, 2])
  end

  it "ignores the opponent's graveyard" do
    goyf = ResolvePermanent("Nethergoyf", owner: p1)
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    game.tick!

    expect(goyf.power).to eq(0)
  end

  context "escape" do
    before do
      p1.graveyard.add(card)
      p1.add_mana(black: 3)
    end

    it "casts from the graveyard exiling cards with four or more card types" do
      others = bury("Grizzly Bears", "Forest", "Lightning Bolt", "Sol Ring")
      p1.cast_as(:escape, card:) do |a|
        a.escape_exile(others)
        a.pay_mana(generic: { black: 2 }, black: 1)
      end
      game.stack.resolve!
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Nethergoyf")
      expect(p1.graveyard.cards).to be_empty
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears", "Forest", "Lightning Bolt", "Sol Ring")
    end

    it "rejects cards with fewer than four card types" do
      others = bury("Grizzly Bears", "Forest", "Lightning Bolt")

      expect do
        p1.cast_as(:escape, card:) do |a|
          a.escape_exile(others)
          a.pay_mana(generic: { black: 2 }, black: 1)
        end
      end.to raise_error(ArgumentError, /escape cost/)
    end
  end
end
