# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InvertPolarity do
  include_context "two player game"

  let(:invert_polarity) { Card("Invert Polarity", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }

  before do
    go_to_main_phase_for!(p2)
    p2.add_mana(green: 2)
    p2.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    p1.add_mana(blue: 2, red: 1)
  end

  def invert!
    p1.cast(card: invert_polarity) { |a| a.pay_mana(blue: 2, red: 1); a.targeting(game.stack.spells.first) }
    game.stack.resolve!
    game.settle!
  end

  it "counters the spell when the flip is lost" do
    allow(p1).to receive(:flip_coin!).and_return(false)
    invert!

    expect(p2.graveyard.cards).to include(bears)
    expect(p2.creatures).to be_empty
    expect(p1.creatures).to be_empty
  end

  it "gives the spell to the caster when the flip is won" do
    allow(p1).to receive(:flip_coin!).and_return(true)
    invert!
    game.stack.resolve!
    game.settle!

    expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
    expect(p2.creatures).to be_empty
  end

  context "when the stolen spell has targets" do
    let(:shock) { Card("Shock", owner: p2) }

    before do
      p2.add_mana(red: 1)
      p2.cast(card: shock) { |a| a.pay_mana(red: 1).targeting(p1) }
    end

    it "lets the caster choose a new target after winning the flip" do
      allow(p1).to receive(:flip_coin!).and_return(true)
      p1.cast(card: invert_polarity) do |a|
        a.pay_mana(blue: 2, red: 1)
        a.targeting(game.stack.spells.find { _1.card == shock })
      end
      game.stack.resolve!
      game.settle!

      expect(game.choices.first).to be_a(Magic::Cards::DeflectingSwat::MayRetargetChoice)
      game.resolve_choice!
      game.resolve_choice!(target: p2)
      game.stack.resolve!

      expect(p2.life).to eq(18)
      expect(p1.life).to eq(20)
    end
  end
end
