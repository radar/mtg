# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- creatures that can't block, and attackers that can't be blocked" do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
  end

  it "refuses a blocker that can't block (Bloodghast)" do
    bloodghast = ResolvePermanent("Bloodghast", owner: p2)

    expect(current_turn.can_block?(attacker: bears, blocker: bloodghast)).to eq(false)
    expect { current_turn.declare_blocker(bloodghast, attacker: bears) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  it "refuses to block an attacker that can't be blocked" do
    allow(bears.card).to receive(:can_be_blocked?).and_return(false)
    blocker = ResolvePermanent("Wood Elves", owner: p2)

    expect { current_turn.declare_blocker(blocker, attacker: bears) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  it "lets a token block" do
    token_class = Magic::Token.create("Soldier") do
      creature_type "Soldier"
      power 1
      toughness 1
    end
    token = token_class.new(game: game, owner: p2).resolve!

    expect { current_turn.declare_blocker(token, attacker: bears) }.not_to raise_error
  end
end
