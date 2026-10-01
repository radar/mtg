# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DalkovanPackbeasts do
  include_context "two player game"

  let!(:ox) { ResolvePermanent("Dalkovan Packbeasts", owner: p1) }
  def warriors = p1.creatures.select { _1.name == "Warrior" }

  it "is a 0/4 with vigilance" do
    expect([ox.power, ox.toughness]).to eq([0, 4])
    expect(ox).to have_keyword(Magic::Cards::Keywords::VIGILANCE)
  end

  it "mobilizes 3 when it attacks, leaving itself untapped" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: ox, target: p2)
    current_turn.attackers_declared!

    expect(warriors.size).to eq(3)
    expect(warriors).to all(be_tapped)
    expect(ox).not_to be_tapped
    go_to_combat_damage!
    expect(p2.life).to eq(17)
  end
end
