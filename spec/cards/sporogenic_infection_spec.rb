# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SporogenicInfection do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:watchdog) { ResolvePermanent("Alpine Watchdog", owner: p2) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p2) }

  before do
    p1.add_mana(black: 2)
    p1.cast(card: Card("Sporogenic Infection", owner: p1)) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(rival) }
    game.stack.resolve!
    game.settle!
  end

  let(:aura) { p1.permanents.by_name("Sporogenic Infection").first }

  it "attaches to the targeted creature" do
    expect(aura.attached_to).to eq(rival)
  end

  context "when it enters" do
    before do
      game.resolve_choice!(target: p2)
      game.settle!
    end

    it "offers every creature of that player other than the enchanted one" do
      expect(game.choices.first.choices).to contain_exactly(watchdog, elves)
    end

    it "makes the player sacrifice the creature they choose" do
      game.resolve_choice!(target: watchdog)
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to eq(["Alpine Watchdog"])
      expect(rival.zone).to be_battlefield
    end
  end

  context "when the enchanted creature is dealt damage" do
    before do
      game.resolve_choice!(target: p2)
      game.resolve_choice!(target: watchdog)
      game.settle!
    end

    it "destroys it" do
      game.add_effect(Magic::Effects::DealDamage.new(source: p1, target: rival, damage: 1))
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end
end
