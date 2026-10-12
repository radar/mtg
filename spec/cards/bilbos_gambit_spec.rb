# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BilbosGambit do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:bolt) { Card("Lightning Bolt", owner: p2) }
  let!(:bolt_cast) do
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) do |a|
      a.pay_mana(red: 1)
      a.targeting(p1)
    end
  end

  def gambit(gift:)
    card = Card("Bilbo's Gambit", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 2)
    p1.cast(card:) do |a|
      a.pay_mana(generic: { white: 1 }, white: 1)
      a.targeting(bolt_cast)
      a.pay_kicker(nil) if gift
    end
    game.stack.resolve!
    game.settle!
  end

  it "returns target spell to its owner's hand without the gift" do
    expect { gambit(gift: false) }.not_to change { p1.life }

    expect(p2.hand.cards).to include(bolt)
    expect(game.stack.spells).to be_empty
  end

  it "does not give a Treasure or stop spells without the gift" do
    gambit(gift: false)

    expect(game.battlefield.controlled_by(p2).select { _1.type?("Treasure") }).to be_empty
    expect(p1.spell_cast_limit_reached?).to be_falsey
    expect(p2.spell_cast_limit_reached?).to be_falsey
  end

  context "when the gift was promised" do
    it "gives the opponent a Treasure" do
      gambit(gift: true)

      treasures = game.battlefield.controlled_by(p2).select { _1.type?("Treasure") }
      expect(treasures.size).to eq(1)
    end

    it "still returns the spell to its owner's hand" do
      gambit(gift: true)

      expect(p2.hand.cards).to include(bolt)
    end

    it "stops all players casting spells this turn" do
      gambit(gift: true)

      expect(p1.spell_cast_limit_reached?).to be(true)
      expect(p2.spell_cast_limit_reached?).to be(true)
    end
  end
end
