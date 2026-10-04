# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CephalidInkmage do
  include_context "two player game"

  let!(:inkmage) { ResolvePermanent("Cephalid Inkmage", owner: p1) }

  def fill_graveyard(count)
    count.times { p1.graveyard.add(Card("Forest", owner: p1)) }
  end

  # The first game turn is p1's; the blocker belongs to p2, so attack on p1's turn.
  def attack_and_try_to_block
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(inkmage, target: p2)
    current_turn.attackers_declared!
    [blocker, current_turn.can_block?(attacker: inkmage, blocker: blocker)]
  end

  it "is a 2/2 Octopus Wizard" do
    expect([inkmage.power, inkmage.toughness]).to eq([2, 2])
  end

  it "surveils 3 when it enters" do
    ResolvePermanent("Cephalid Inkmage", owner: p1, settle: false)
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "can be blocked with fewer than seven cards in your graveyard" do
    fill_graveyard(6)
    _blocker, can_block = attack_and_try_to_block

    expect(can_block).to eq(true)
  end

  it "can't be blocked with seven or more cards in your graveyard" do
    fill_graveyard(7)
    blocker, can_block = attack_and_try_to_block

    expect(can_block).to eq(false)
    expect { current_turn.declare_blocker(blocker, attacker: inkmage) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end

  it "doesn't count the opponent's graveyard" do
    7.times { p2.graveyard.add(Card("Forest", owner: p2)) }
    _blocker, can_block = attack_and_try_to_block

    expect(can_block).to eq(true)
  end
end
