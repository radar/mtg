# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NullElementalBlast do
  include_context "two player game"

  let(:blast) { Card("Null Elemental Blast", owner: p1) }

  before { p1.hand.add(blast) }

  def cast_blast(mode, target)
    p1.add_mana(colorless: 1)
    p1.cast(card: blast) do |action|
      action.pay_mana(colorless: 1)
      action.choose_mode(mode) { _1.targeting(target) }
    end
    game.stack.resolve!
  end

  describe "destroy target multicolored permanent" do
    let!(:houndmaster) { ResolvePermanent("Alpine Houndmaster", owner: p2) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { game.skip_choice! }

    it "only targets multicolored permanents" do
      mode = described_class::DestroyMulticoloredPermanent.new(game: game, card: blast)

      expect(mode.target_choices).to contain_exactly(houndmaster)
    end

    it "destroys the permanent" do
      cast_blast(described_class::DestroyMulticoloredPermanent, houndmaster)

      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to eq(["Alpine Houndmaster"])
      expect(p2.creatures).to contain_exactly(bears)
    end
  end

  describe "counter target multicolored spell" do
    let(:houndmaster) { Card("Alpine Houndmaster", owner: p2) }
    let(:bolt) { Card("Lightning Bolt", owner: p2) }

    before do
      go_to_main_phase_for!(p2)
      p2.hand.add(houndmaster)
      p2.hand.add(bolt)
    end

    def cast_houndmaster
      p2.add_mana(red: 2, white: 1)
      p2.cast(card: houndmaster) { _1.pay_mana(red: 1, white: 1, generic: { red: 1 }) }
    end

    def cast_bolt
      p2.add_mana(red: 1)
      p2.cast(card: bolt) do |a|
        a.pay_mana(red: 1)
        a.targeting(p1)
      end
    end

    it "only targets multicolored spells" do
      cast_houndmaster
      cast_bolt

      mode = described_class::CounterMulticoloredSpell.new(game: game, card: blast)

      expect(mode.target_choices.map(&:card)).to contain_exactly(houndmaster)
    end

    it "counters the spell" do
      cast_houndmaster
      cast_blast(described_class::CounterMulticoloredSpell, game.stack.spells.last)

      expect(p2.graveyard.cards).to include(houndmaster)
      expect(p2.creatures.map(&:name)).not_to include("Alpine Houndmaster")
    end
  end
end
