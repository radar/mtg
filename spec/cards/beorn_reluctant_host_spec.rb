# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BeornReluctantHost do
  include_context "two player game"

  let(:card) { Card("Beorn, Reluctant Host", owner: p1) }

  before { p1.hand.add(card) }

  it "is a 5/5 legendary Human Bear Shapeshifter with trample" do
    beorn = ResolvePermanent("Beorn, Reluctant Host", owner: p1)

    expect([beorn.power, beorn.toughness]).to eq([5, 5])
    expect(beorn.card.types).to include("Human", "Bear", "Shapeshifter")
    expect(beorn.trample?).to be(true)
  end

  describe "Till and Tend" do
    before { go_to_main_phase! }

    it "lets you play an additional land this turn, then exiles on an adventure" do
      p1.add_mana(green: 2)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!

      p1.play_land(land: Card("Forest", owner: p1))
      expect { p1.play_land(land: Card("Forest", owner: p1)) }.not_to raise_error
      expect(card.zone).to be_exile
      expect(card.on_adventure).to eq(true)
    end

    it "doesn't allow a second land without it" do
      p1.play_land(land: Card("Forest", owner: p1))

      expect { p1.play_land(land: Card("Forest", owner: p1)) }.to raise_error(Magic::IllegalAction)
    end

    it "can then be cast as the creature from exile" do
      p1.add_mana(green: 2)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!
      p1.add_mana(green: 5)
      p1.cast(card:) { _1.pay_mana(generic: { green: 4 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Beorn, Reluctant Host")
    end
  end
end
