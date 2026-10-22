# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TempestHarvester do
  include_context "two player game"

  let!(:harvester) { ResolvePermanent("Tempest Harvester", owner: p1) }

  def loot = harvester.activated_abilities.first

  it "is a 2/1 Merfolk Wizard" do
    expect([harvester.power, harvester.toughness]).to eq([2, 1])
    expect(harvester.type?("Merfolk")).to be(true)
    expect(harvester.type?("Wizard")).to be(true)
  end

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  it "taps and pays {E} to draw a card, then discard a card" do
    hand_before = p1.hand.count
    p1.activate_ability(ability: loot)
    game.stack.resolve!
    game.settle!

    expect(harvester).to be_tapped
    expect(p1.energy).to eq(1)
    expect(p1.hand.count).to eq(hand_before + 1)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)

    card = p1.hand.cards.first
    game.resolve_choice!(card: card)
    expect(p1.hand.count).to eq(hand_before)
    expect(p1.graveyard.cards).to include(card)
  end

  it "can't be activated while tapped" do
    harvester.tap!
    expect { p1.activate_ability(ability: loot) }.to raise_error(Magic::IllegalAction)
    expect(p1.energy).to eq(2)
  end

  it "can't be activated without energy" do
    p1.pay_energy!(2)
    expect { p1.activate_ability(ability: loot) }.to raise_error(StandardError)
    expect(game.choices).to be_empty
  end
end
