# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CrackedSkull do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:bolt) { Card("Lightning Bolt", owner: p2) }
  let(:forest) { Card("Forest", owner: p2) }

  before do
    [*p2.hand.cards].each { p2.hand.remove(_1) }
    p2.hand.add(bolt)
    p2.hand.add(forest)
    p1.add_mana(black: 3)
    p1.cast(card: Card("Cracked Skull", owner: p1)) { |a| a.pay_mana(generic: { black: 2 }, black: 1).targeting(rival) }
    game.stack.resolve!
    game.settle!
  end

  let(:skull) { p1.permanents.by_name("Cracked Skull").first }

  it "attaches to the targeted creature" do
    expect(skull.attached_to).to eq(rival)
  end

  context "when it enters" do
    before do
      game.resolve_choice!(target: p2)
      game.settle!
    end

    it "lets you choose a nonland card from the hand, and that player discards it" do
      game.resolve_choice!
      game.resolve_choice!(target: bolt)
      game.settle!

      expect(p2.graveyard.cards).to include(bolt)
      expect(p2.hand.cards).to include(forest)
    end

    it "only offers nonland cards" do
      game.resolve_choice!

      expect(game.choices.first.choices).to eq([bolt])
    end

    it "lets you decline to choose a card" do
      game.skip_choice!
      game.settle!

      expect(p2.hand.cards).to include(bolt, forest)
    end
  end

  context "when the enchanted creature is dealt damage" do
    before do
      game.resolve_choice!(target: p2)
      game.settle!
      game.skip_choice!
      game.settle!
    end

    it "destroys it" do
      game.add_effect(Magic::Effects::DealDamage.new(source: p1, target: rival, damage: 1))
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end
end
