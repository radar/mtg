# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheTaleOfTamiyo do
  include_context "two player game"

  # Seven opening cards, the draw step's card, then: Forest and Forest (share a type: draw, repeat), Grizzly Bears and
  # Lightning Bolt (share none), with a Plains drawn in between and Islands after.
  def p1_library
    [*7.times.map { Card("Forest", owner: p1) }, Card("Island", owner: p1),
     Card("Forest", owner: p1), Card("Forest", owner: p1), Card("Plains", owner: p1),
     Card("Grizzly Bears", owner: p1), Card("Lightning Bolt", owner: p1),
     *6.times.map { Card("Island", owner: p1) }]
  end

  let(:card) { Card("The Tale Of Tamiyo", owner: p1) }
  let(:saga) { p1.permanents.find { _1.card == card } }

  def cast!
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(blue: 3)
    p1.cast(card:) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "is a legendary Saga with four chapters" do
    cast!

    expect(saga.card).to be_legendary
    expect(saga.card.chapters.size).to eq(4)
  end

  describe "chapter I" do
    it "mills two cards, and while two milled cards share a card type, draws a card and repeats" do
      cast!
      names = p1.graveyard.cards.map(&:name)

      # Forest + Forest share a type: draw (the Plains) and repeat; Grizzly Bears + Lightning Bolt don't: stop.
      expect(names).to include("Forest", "Grizzly Bears", "Lightning Bolt")
      expect(p1.hand.cards.map(&:name)).to include("Plains")
      expect(p1.graveyard.cards.count { _1.name == "Forest" }).to eq(2)
    end

    it "stops after one mill when the two cards share nothing" do
      p1.library.cards.to_a.dup.each { p1.library.remove(_1) }
      [Card("Island", owner: p1), Card("Grizzly Bears", owner: p1), Card("Lightning Bolt", owner: p1), Card("Forest", owner: p1)].reverse_each { p1.library.add(_1) }
      cast!

      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears", "Lightning Bolt")
    end

    it "stops when the library runs out" do
      p1.library.cards.to_a.dup.each { p1.library.remove(_1) }
      p1.library.add(Card("Forest", owner: p1))
      expect { cast! }.not_to raise_error
    end
  end

  describe "chapter IV" do
    let!(:permanent) { ResolvePermanent("The Tale Of Tamiyo", owner: p1) }
    let!(:bolt) { Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:strike) { Card("Sure Strike", owner: p1).tap { p1.graveyard.add(_1) } }

    before do
      game.choices.to_a.dup.each { game.skip_choice! } # chapter I
      described_class::ExileChapter.new(actor: permanent).resolve!
    end

    it "offers instants and sorceries from your graveyard" do
      expect(game.choices.last.choices).to include(bolt, strike)
      expect(game.choices.last.choices).not_to include(bears)
    end

    it "exiles the chosen cards, then lets you cast a copy of each" do
      game.resolve_choice!(targets: [bolt])

      expect(bolt.zone).to be_exile
      expect(game.choices.last).to be_a(Magic::Choice::MayCastCopy)
      game.resolve_choice!
      game.resolve_choice!(target: p2)

      expect(p2.life).to eq(17)
    end

    it "lets you decline the copies" do
      game.resolve_choice!(targets: [bolt])
      game.skip_choice!

      expect(p2.life).to eq(20)
      expect(bolt.zone).to be_exile
    end

    it "may exile any number, including none" do
      game.resolve_choice!(targets: [])

      expect(bolt.zone).to be_graveyard
    end
  end
end
