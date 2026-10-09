# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RhovanionRampager do
  include_context "two player game"

  let!(:rampager) { ResolvePermanent("Rhovanion Rampager", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(rampager, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 3/2 Wolf" do
    expect([rampager.power, rampager.toughness]).to eq([3, 2])
  end

  it "may sacrifice another creature when attacking to gain counters equal to its power" do
    bear = ResolvePermanent("Ordinary Bear", owner: p1)
    attack
    game.resolve_choice!(sacrifice: bear)
    game.tick!

    expect(bear.card.zone).to be_graveyard
    expect(rampager.power).to eq(7)
  end

  it "can decline to sacrifice" do
    bear = ResolvePermanent("Ordinary Bear", owner: p1)
    attack
    game.skip_choice!

    expect(p1.creatures).to include(bear)
    expect(rampager.power).to eq(3)
  end

  it "doesn't ask when there is nothing else to sacrifice" do
    attack

    expect(game.choices).to be_empty
  end

  it "amasses Goblins X, where X is its power, when it dies" do
    rampager.destroy!
    game.settle!
    armies = p1.creatures.select { _1.type?("Army") }

    expect(armies.count).to eq(1)
    expect(armies.first.type?("Goblin")).to be(true)
    expect(armies.first.power).to eq(3)
  end
end
