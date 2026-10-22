# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WumpusAberration do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:wumpus) { Card("Wumpus Aberration", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) } }
  let!(:sol_ring) { Card("Sol Ring", owner: p2).tap { p2.hand.add(_1) } }

  def cast_with_green
    p1.add_mana(green: 4)
    p1.cast(card: wumpus) { _1.pay_mana(generic: { green: 3 }, green: 1) }
    game.settle!
  end

  def cast_with_colorless
    p1.add_mana(green: 1, colorless: 3)
    p1.cast(card: wumpus) { _1.pay_mana(generic: { colorless: 3 }, green: 1) }
    game.settle!
  end

  it "is a devoid 6/6 trampler" do
    permanent = ResolvePermanent("Wumpus Aberration", owner: p1)

    expect(permanent.colors).to be_empty
    expect([permanent.power, permanent.toughness]).to eq([6, 6])
    expect(permanent.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to be(true)
  end

  context "when no colorless mana was spent" do
    before { cast_with_green }

    it "offers the opponent only creature cards from their hand" do
      choice = game.choices.first
      expect(choice.chooser).to eq(p2)
      expect(choice.choices).to eq([bears])
    end

    it "lets the opponent put the creature onto the battlefield under their control" do
      game.resolve_choice!(targets: [bears])
      game.settle!

      expect(p2.creatures.map(&:name)).to eq(["Grizzly Bears"])
      expect(p2.hand.cards).to include(sol_ring)
      expect(p2.hand.cards).not_to include(bears)
      expect(p1.creatures.map(&:name)).to include("Wumpus Aberration")
    end

    it "does nothing if the opponent declines" do
      game.skip_choice!
      game.settle!

      expect(p2.creatures).to be_empty
      expect(p2.hand.cards).to include(bears)
    end

    it "rejects a non-creature card" do
      expect { game.resolve_choice!(targets: [sol_ring]) }.to raise_error(ArgumentError, /Sol Ring/)
    end
  end

  it "does not trigger if colorless mana was spent to cast it" do
    cast_with_colorless

    expect(game.choices).to be_empty
    expect(p2.creatures).to be_empty
    expect(p1.creatures.map(&:name)).to include("Wumpus Aberration")
  end

  it "offers nothing if the opponent has no creature card in hand" do
    p2.hand.remove(bears)
    cast_with_green

    expect(game.choices).to be_empty
  end
end
