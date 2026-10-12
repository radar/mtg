# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MistyMountainsRaider do
  include_context "two player game"

  let!(:raider) { ResolvePermanent("Misty Mountains Raider", owner: p1) }

  def armies = p1.creatures.select { _1.types.include?("Army") }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
  end

  it "is a 4/4" do
    expect(raider.power).to eq(4)
  end

  it "amasses Goblins 2 whenever you attack" do
    attack_with(raider)
    game.settle!
    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(2)
  end

  it "does not amass when it did not attack" do
    skip_to_combat!
    expect(armies).to be_empty
  end
end
