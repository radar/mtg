# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GalvanicDischarge do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def discharge(target)
    p1.add_mana(red: 1)
    p1.cast(card: Card("Galvanic Discharge", owner: p1)) do |action|
      action.pay_mana(red: 1)
      action.targeting(target)
    end
    game.stack.resolve!
  end

  it "gives you three energy, then asks how much to pay" do
    discharge(bears)

    expect(p1.energy).to eq(3)
    expect(game.choices.first).to be_a(Magic::Choice::PayAnyEnergy)
  end

  it "deals damage equal to the energy paid" do
    discharge(bears)
    game.resolve_choice!(amount: 2)
    game.settle!

    expect(p1.energy).to eq(1)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "deals only as much damage as the energy paid" do
    discharge(bears)
    game.resolve_choice!(amount: 1)
    game.settle!

    expect(p1.energy).to eq(2)
    expect(bears.damage).to eq(1)
    expect(bears.zone).to eq(game.battlefield)
  end

  it "can't pay more energy than you have" do
    discharge(bears)
    game.resolve_choice!(amount: 10)
    game.settle!

    expect(p1.energy).to eq(0)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "deals no damage and keeps the energy when you decline" do
    discharge(bears)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(3)
    expect(bears.damage).to eq(0)
  end

  context "targeting a planeswalker" do
    let!(:walker) { ResolvePermanent("Basri Ket", owner: p2) }

    it "can target it, and the damage removes loyalty" do
      expect(Card("Galvanic Discharge", owner: p1).target_choices).to include(walker)
      loyalty = walker.loyalty

      discharge(walker)
      game.resolve_choice!(amount: 2)
      game.settle!

      expect(walker.loyalty).to eq(loyalty - 2)
    end
  end

  it "targets only creatures and planeswalkers, not players" do
    card = Card("Galvanic Discharge", owner: p1)
    expect(card.target_choices).to include(bears)
    expect(card.target_choices).not_to include(p2)
  end
end
