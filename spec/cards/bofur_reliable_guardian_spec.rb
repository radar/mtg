# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BofurReliableGuardian do
  include_context "two player game"

  let(:card) { Card("Bofur, Reliable Guardian", owner: p1) }

  before { p1.hand.add(card) }

  it "is a 1/1 legendary Dwarf Scout with lifelink" do
    bofur = ResolvePermanent("Bofur, Reliable Guardian", owner: p1)

    expect([bofur.power, bofur.toughness]).to eq([1, 1])
    expect(bofur.card.types).to include("Dwarf", "Scout")
    expect(bofur).to have_keyword(:lifelink)
  end

  describe "Concerted Care" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def cast_care(target)
      p1.add_mana(white: 2)
      p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(target) }
      game.stack.resolve!
      game.tick!
    end

    it "gives a creature you control hexproof and indestructible, then exiles on an adventure" do
      cast_care(bears)

      expect(bears).to have_keyword(:hexproof)
      expect(bears).to have_keyword(:indestructible)
      expect(card.zone).to be_exile
      expect(card.on_adventure).to eq(true)
    end

    it "works on an artifact you control" do
      ring = ResolvePermanent("Sol Ring", owner: p1)
      cast_care(ring)

      expect(ring).to have_keyword(:hexproof)
    end

    it "can be cast at instant speed" do
      go_to_main_phase_for!(p2)

      expect { cast_care(bears) }.not_to raise_error
    end

    it "can't target an opponent's creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(white: 2)

      expect {
        p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(theirs) }
      }.to raise_error(StandardError)
    end

    it "can then be cast as the creature from exile" do
      cast_care(bears)
      go_to_main_phase!
      p1.add_mana(white: 1)
      p1.cast(card:) { _1.pay_mana(white: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Bofur, Reliable Guardian")
    end
  end
end
