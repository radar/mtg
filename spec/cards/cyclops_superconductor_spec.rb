# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CyclopsSuperconductor do
  include_context "two player game"

  let!(:cyclops) { ResolvePermanent("Cyclops Superconductor", owner: p1) }

  def kill
    cyclops.destroy!
    game.settle!
  end

  it "is a 2/2 Cyclops Wizard with prowess" do
    expect([cyclops.power, cyclops.toughness]).to eq([2, 2])
    expect(cyclops.type?("Cyclops")).to be(true)
    expect(cyclops.type?("Wizard")).to be(true)
    expect(cyclops.keywords).to include(Magic::Cards::Keywords::PROWESS)
  end

  it "gives you three energy when it enters" do
    expect(p1.energy).to eq(3)
  end

  describe "prowess" do
    before do
      go_to_main_phase!
      p1.add_mana(red: 1)
    end

    def cast_shock
      p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1); a.targeting(p2) }
      game.settle!
    end

    it "gets +1/+1 until end of turn when you cast a noncreature spell" do
      cast_shock
      expect([cyclops.power, cyclops.toughness]).to eq([3, 3])

      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      expect([cyclops.power, cyclops.toughness]).to eq([2, 2])
    end

    it "deals its boosted power when it dies in response" do
      cast_shock
      kill
      game.resolve_choice!
      game.resolve_choice!(target: p2)
      game.settle!

      expect(p2.life).to eq(15)
    end
  end

  describe "when it dies" do
    it "pays EEE to deal damage equal to its power to a creature" do
      opp = ResolvePermanent("Grizzly Bears", owner: p2)
      kill
      expect(game.choices.first).to be_a(Magic::Choice::PayEnergy)
      game.resolve_choice!
      game.resolve_choice!(target: opp)
      game.settle!

      expect(p1.energy).to eq(0)
      expect(opp.damage).to eq(2)
    end

    it "can hit a player" do
      kill
      game.resolve_choice!
      game.resolve_choice!(target: p2)
      game.settle!

      expect(p2.life).to eq(18)
    end

    it "does nothing when you decline" do
      kill
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(3)
      expect(p2.life).to eq(20)
      expect(game.choices).to be_empty
    end

    it "offers nothing with fewer than three energy" do
      p1.pay_energy!(1)
      kill

      expect(game.choices).to be_empty
      expect(p2.life).to eq(20)
    end
  end
end
