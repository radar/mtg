# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnterTheEnigma do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:enigma) { Card("Enter The Enigma", owner: p1) }

  before do
    p1.hand.add(enigma)
    p1.add_mana(blue: 1)
  end

  def cast!
    cast_and_resolve(card: enigma, player: p1, targeting: bears) { |a| a.pay_mana(blue: 1) }
    game.tick!
  end

  it "makes the target creature unblockable this turn" do
    cast!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect { current_turn.declare_blocker(blocker, attacker: bears) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  it "draws a card" do
    expect(p1).to receive(:draw!)
    cast!
  end

  it "goes to the graveyard" do
    cast!

    expect(enigma.zone).to be_graveyard
  end
end
