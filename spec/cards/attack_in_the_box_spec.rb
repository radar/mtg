# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AttackInTheBox do
  include_context "two player game"

  let!(:toy) { ResolvePermanent("Attack-In-The-Box", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: toy, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 2/4 artifact creature" do
    expect([toy.power, toy.toughness]).to eq([2, 4])
    expect(toy.type?("Artifact")).to be(true)
  end

  it "may get +4/+0 when it attacks, and is sacrificed at the next end step" do
    attack!
    game.resolve_choice!

    expect(toy.power).to eq(6)

    current_turn.end!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Attack-in-the-Box")
  end

  it "stays a 2/4 and survives if you decline" do
    attack!
    game.skip_choice!

    expect(toy.power).to eq(2)

    current_turn.end!
    game.settle!

    expect(p1.creatures).to include(toy)
  end
end
