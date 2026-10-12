# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElderGargaroth do
  include_context "two player game"

  let!(:gargaroth) { ResolvePermanent("Elder Gargaroth", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: gargaroth, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 6/6 Beast with reach, vigilance and trample" do
    expect([gargaroth.power, gargaroth.toughness]).to eq([6, 6])
    expect(gargaroth).to be_reach
    expect(gargaroth).to be_vigilant
    expect(gargaroth.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
  end

  context "when it attacks" do
    before { attack }

    it "can create a 3/3 Beast" do
      game.resolve_choice!(mode: :token)
      game.settle!

      beast = p1.creatures.by_name("Beast").first
      expect([beast.power, beast.toughness]).to eq([3, 3])
    end

    it "can gain 3 life" do
      game.resolve_choice!(mode: :life)
      game.settle!

      expect(p1.life).to eq(23)
    end

    it "can draw a card" do
      hand_size = p1.hand.count
      game.resolve_choice!(mode: :draw)
      game.settle!

      expect(p1.hand.count).to eq(hand_size + 1)
    end
  end

  it "triggers when it blocks" do
    go_to_main_phase_for!(p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker:, target: p1)
    current_turn.attackers_declared!
    current_turn.declare_blocker(gargaroth, attacker:)
    game.settle!
    game.resolve_choice!(mode: :life)
    game.settle!

    expect(p1.life).to eq(23)
  end
end
