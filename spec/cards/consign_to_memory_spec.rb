# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ConsignToMemory do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:consign) { Card("Consign To Memory", owner: p1) }

  it "counters a colorless spell" do
    p1.add_mana(red: 2)
    p1.cast(card: Card("Rakdos Signet", owner: p1)) { |a| a.pay_mana(generic: { red: 2 }) }
    signet_spell = game.stack.spells.first

    p1.add_mana(blue: 1)
    p1.cast(card: consign) { |a| a.pay_mana(blue: 1).targeting(signet_spell) }
    game.stack.resolve!

    expect(game.stack.spells).to be_empty
    expect(p1.graveyard.cards.map(&:name)).to include("Rakdos Signet")
  end

  it "cannot target a coloured spell" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }

    expect(consign.target_choices).to be_empty
  end

  it "costs {1} more for each replicate" do
    p1.add_mana(red: 2)
    p1.cast(card: Card("Rakdos Signet", owner: p1)) { |a| a.pay_mana(generic: { red: 2 }) }
    signet_spell = game.stack.spells.first

    p1.add_mana(blue: 2)
    expect do
      p1.cast(card: consign) do |a|
        a.replicate(2)
        a.pay_mana(blue: 1, generic: { blue: 1 }).targeting(signet_spell)
      end
    end.to raise_error(Magic::Costs::Mana::CannotPay)
  end

  it "copies itself once per replicate paid" do
    p1.add_mana(red: 2)
    p1.cast(card: Card("Rakdos Signet", owner: p1)) { |a| a.pay_mana(generic: { red: 2 }) }
    signet_spell = game.stack.spells.first

    p1.add_mana(blue: 3)
    p1.cast(card: consign) do |a|
      a.replicate(2)
      a.pay_mana(blue: 1, generic: { blue: 2 }).targeting(signet_spell)
    end

    expect(game.choices.first).to be_a(Magic::Choice::MayCopyTargets)
  end
end
