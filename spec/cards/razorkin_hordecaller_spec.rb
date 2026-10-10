# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RazorkinHordecaller do
  include_context "two player game"

  let!(:hordecaller) { ResolvePermanent("Razorkin Hordecaller", owner: p1) }

  def tokens = p1.creatures.select { _1.name == "Gremlin" }

  it "is a 4/4 with haste" do
    expect([hordecaller.power, hordecaller.toughness]).to eq([4, 4])
    expect(hordecaller).to be_haste
  end

  it "creates a 1/1 red Gremlin when you attack" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hordecaller, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.tick!

    expect(tokens.count).to eq(1)
    expect([tokens.first.power, tokens.first.toughness]).to eq([1, 1])
  end
end
