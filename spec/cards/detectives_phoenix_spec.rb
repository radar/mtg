# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DetectivesPhoenix do
  include_context "two player game"

  before { go_to_main_phase! }

  it "is a 2/2 flying, haste creature" do
    phoenix = ResolvePermanent("Detective's Phoenix", owner: p1)
    expect([phoenix.power, phoenix.toughness]).to eq([2, 2])
    expect(phoenix).to be_flying
    expect(phoenix).to be_haste
  end

  context "cast from the graveyard with bestow" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let(:phoenix) { Card("Detective's Phoenix", owner: p1) }
    let(:evidence) { [Card("Serra Angel", owner: p1), Card("Doom Blade", owner: p1)] }

    before do
      p1.graveyard.add(phoenix)
      evidence.each { p1.graveyard.add(_1) }
    end

    def bestow!(cards = evidence)
      p1.add_mana(red: 1)
      p1.cast_as(:bestowed, card: phoenix) do |a|
        a.collect_evidence(cards)
        a.pay_mana(red: 1)
        a.targeting(bears)
      end
      game.settle!
    end

    it "exiles the evidence, attaches to the creature and buffs it" do
      bestow!

      expect(bears.power).to eq(4)
      expect(bears.toughness).to eq(4)
      expect(bears).to be_flying
      expect(bears).to be_haste
      expect(evidence.map(&:zone)).to all(satisfy { _1.exile? })
    end

    it "needs evidence with total mana value of 6 or more" do
      expect { bestow!([evidence.last]) }.to raise_error(ArgumentError, /total mana value/)
    end

    it "is illegal without collecting evidence" do
      p1.add_mana(red: 1)
      expect do
        p1.cast_as(:bestowed, card: phoenix) { |a| a.pay_mana(red: 1); a.targeting(bears) }
      end.to raise_error(Magic::IllegalAction, /evidence/)
    end
  end
end
