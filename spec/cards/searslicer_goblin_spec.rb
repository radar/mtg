# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SearslicerGoblin do
  include_context "two player game"

  let!(:goblin) { ResolvePermanent("Searslicer Goblin", owner: p1) }

  def goblin_tokens = p1.creatures.select(&:token?).select { _1.name == "Goblin" }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(goblin, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def end_step!
    current_turn.end!
    game.settle!
  end

  it "is a 2/1 Goblin Warrior" do
    expect([goblin.power, goblin.toughness]).to eq([2, 1])
  end

  it "creates a 1/1 red Goblin token at your end step if you attacked this turn" do
    attack!
    end_step!

    expect(goblin_tokens.count).to eq(1)
    expect([goblin_tokens.first.power, goblin_tokens.first.toughness]).to eq([1, 1])
  end

  it "does nothing if you didn't attack" do
    go_to_main_phase!
    end_step!

    expect(goblin_tokens).to be_empty
  end

  it "does nothing at the opponent's end step" do
    attack!
    game.next_turn
    go_to_main_phase_for!(p2)
    end_step!

    expect(goblin_tokens).to be_empty
  end
end
