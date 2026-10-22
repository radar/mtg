# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AetherSpike do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def p2_casts_growth
    go_to_main_phase_for!(p2)
    p2.add_mana(green: 2)
    p2.cast(card: Card("Titanic Growth", owner: p2)) do |action|
      action.auto_pay_mana
      action.targeting(bears)
    end
    game.stack.spells.first
  end

  def spike(spell)
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Aether Spike", owner: p1)) do |action|
      action.pay_mana(generic: { blue: 1 }, blue: 1)
      action.targeting(spell)
    end
    game.stack.resolve!
  end

  it "gives you two energy, then asks how much to pay" do
    spike(p2_casts_growth)

    expect(p1.energy).to eq(2)
    expect(game.choices.first).to be_a(Magic::Choice::PayAnyEnergy)
  end

  it "counters the spell when its controller can't pay {1} per energy" do
    spike(p2_casts_growth)
    game.resolve_choice!(amount: 2)
    game.settle!

    expect(p1.energy).to eq(0)
    expect(p2.graveyard.cards.map(&:name)).to include("Titanic Growth")
    expect(bears.power).to eq(2)
  end

  it "counters the spell if its controller declines to pay" do
    spike(p2_casts_growth)
    game.resolve_choice!(amount: 1)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(1)
    expect(p2.graveyard.cards.map(&:name)).to include("Titanic Growth")
  end

  it "lets the spell resolve if its controller pays {1} for each energy paid" do
    spell = p2_casts_growth
    p2.add_mana(green: 2)
    spike(spell)
    game.resolve_choice!(amount: 2)
    game.resolve_choice!
    game.settle!

    expect(bears.power).to eq(6)
  end

  it "doesn't counter the spell when you pay no energy" do
    spike(p2_casts_growth)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(2)
    expect(game.choices).to be_empty
    expect(bears.power).to eq(6)
  end

  it "only targets spells other than itself" do
    spell = p2_casts_growth
    expect(Card("Aether Spike", owner: p1).target_choices).to include(spell)
  end
end
