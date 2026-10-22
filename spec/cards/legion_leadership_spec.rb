# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LegionLeadership do
  include_context "two player game"

  let(:leadership) { Card("Legion Leadership", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(leadership)
  end

  it "is a {1}{R/W} instant with a land back face" do
    expect(leadership.mana_value).to eq(2)
    expect(leadership).to be_instant
    expect(leadership.back_face.name).to eq("Legion Stronghold")
    expect(leadership.back_face).to be_land
  end

  describe "the spell" do
    before do
      p1.add_mana(red: 2)
      p1.cast(card: leadership) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(bears) }
      game.stack.resolve!
      game.settle!
    end

    it "doubles the target creature's power" do
      expect([bears.power, bears.toughness]).to eq([4, 2])
    end

    it "gives it first strike" do
      expect(bears).to be_first_strike
    end

    it "wears off at end of turn" do
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect([bears.power, bears.toughness]).to eq([2, 2])
      expect(bears).not_to be_first_strike
    end
  end

  describe "played as Legion Stronghold" do
    let(:stronghold) { p1.permanents.by_name("Legion Stronghold").first }

    before { p1.play_land(land: leadership, face: :back) }

    it "enters tapped" do
      expect(stronghold).to be_land
      expect(stronghold).to be_tapped
    end

    it "taps for {R}" do
      stronghold.untap!
      p1.activate_ability(ability: stronghold.activated_abilities.first) { _1.choose(:red) }
      expect(p1.mana_pool[:red]).to eq(1)
    end

    it "taps for {W}" do
      stronghold.untap!
      p1.activate_ability(ability: stronghold.activated_abilities.first) { _1.choose(:white) }
      expect(p1.mana_pool[:white]).to eq(1)
    end
  end
end
