# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BilboBagginsBurglar do
  include_context "two player game"

  let(:card) { Card("Bilbo Baggins, Burglar", owner: p1) }

  before { p1.hand.add(card) }

  it "is a 2/1 legendary Halfling Rogue" do
    bilbo = ResolvePermanent("Bilbo Baggins, Burglar", owner: p1)

    expect([bilbo.power, bilbo.toughness]).to eq([2, 1])
    expect(bilbo.card.types).to include("Halfling", "Rogue")
  end

  it "draws a card when it enters" do
    hand = p1.hand.count
    ResolvePermanent("Bilbo Baggins, Burglar", owner: p1)

    expect(p1.hand.count).to eq(hand + 1)
  end

  describe "Take a Glance" do
    before { go_to_main_phase! }

    it "scries 2, then exiles on an adventure" do
      p1.add_mana(blue: 1)
      p1.cast(card:, adventure: true) { _1.pay_mana(blue: 1) }
      game.stack.resolve!

      scry = game.choices.first
      expect(scry).to be_a(Magic::Choice::Scry)
      expect(scry.amount).to eq(2) if scry.respond_to?(:amount)
      expect(card.zone).to be_exile
      expect(card.on_adventure).to eq(true)
    end

    it "can then be cast as the creature from exile" do
      p1.add_mana(blue: 1)
      p1.cast(card:, adventure: true) { _1.pay_mana(blue: 1) }
      game.stack.resolve!
      game.skip_choice! if game.choices.any?
      p1.add_mana(blue: 3)
      p1.cast(card:) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
      game.stack.resolve!
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Bilbo Baggins, Burglar")
    end
  end
end
