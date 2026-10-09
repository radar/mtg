# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NoriTellerOfTales do
  include_context "two player game"

  let!(:nori) { ResolvePermanent("Nori Teller Of Tales", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/2 Dwarf Bard" do
    expect([nori.power, nori.toughness]).to eq([2, 2])
  end

  it "gives target attacking creature first strike when Nori attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(nori, target: p2)
    current_turn.declare_attacker(bear, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.resolve_choice!(target: bear) if game.choices.any?
    game.tick!

    expect(bear).to be_first_strike
  end

  it "doesn't trigger when another creature attacks alone" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bear, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(bear).not_to be_first_strike
  end
end
