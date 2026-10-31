# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SarumanTheWhite do
  include_context "two player game"

  let!(:saruman) { ResolvePermanent("Saruman The White", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

  def cast_island(player = p1)
    player.add_mana(red: 1)
    target = player == p1 ? p2 : p1
    player.cast(card: Card("Burst Lightning", owner: player)) { _1.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "is a 4/4 legendary Avatar Wizard" do
    expect([saruman.power, saruman.toughness]).to eq([4, 4])
    expect(saruman.type?("Wizard")).to eq(true)
  end

  context "ward {2}" do
    let(:bolt) { Card("Burst Lightning", owner: p2) }

    before do
      go_to_main_phase_for!(p2)
      p2.add_mana(red: 1, blue: 2)
      p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(saruman) }
      game.settle!
    end

    it "asks for {2}" do
      expect(game.choices.last).to be_a(Magic::Choice::Ward)
      expect(game.choices.last.generic).to eq(2)
    end

    it "counters the spell when too little is paid" do
      game.resolve_choice!(payment: { blue: 1 })
      game.settle!
      expect(game.stack.spells.map(&:card)).not_to include(bolt)
      expect(p2.graveyard.cards).to include(bolt)
      expect(saruman.damage).to eq(0)
    end

    it "lets the spell resolve when {2} is paid" do
      game.resolve_choice!(payment: { blue: 2 })
      game.settle!
      expect(saruman.damage).to eq(2)
    end
  end

  it "does not amass on the first spell" do
    cast_island
    expect(army).to be_nil
  end

  it "amasses Orcs 2 on the second spell, but not the third" do
    cast_island
    game.stack.resolve!
    cast_island
    game.stack.resolve!
    game.tick!
    expect(army.type?("Orc")).to eq(true)
    expect(army.power).to eq(2)

    cast_island
    game.stack.resolve!
    game.tick!
    expect(army.power).to eq(2)
  end

  it "ignores the opponent's second spell" do
    cast_island(p2)
    game.stack.resolve!
    cast_island(p2)
    game.stack.resolve!
    game.tick!
    expect(army).to be_nil
  end
end
