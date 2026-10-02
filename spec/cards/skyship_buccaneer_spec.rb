# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkyshipBuccaneer do
  include_context "two player game"

  def attack_with_a_creature!
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 4/3 Human Pirate with flying" do
    buccaneer = ResolvePermanent("Skyship Buccaneer", owner: p1)

    expect([buccaneer.power, buccaneer.toughness]).to eq([4, 3])
    expect(buccaneer.flying?).to be(true)
    expect(buccaneer.type?("Pirate")).to be(true)
  end

  it "draws a card when it enters if you attacked this turn (raid)" do
    attack_with_a_creature!
    hand_size = p1.hand.count
    ResolvePermanent("Skyship Buccaneer", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "draws nothing when you did not attack this turn" do
    go_to_main_phase!
    hand_size = p1.hand.count
    ResolvePermanent("Skyship Buccaneer", owner: p1)

    expect(p1.hand.count).to eq(hand_size)
  end
end
