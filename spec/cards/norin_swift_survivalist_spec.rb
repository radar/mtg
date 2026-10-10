# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NorinSwiftSurvivalist do
  include_context "two player game"

  let!(:norin) { ResolvePermanent("Norin, Swift Survivalist", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def attack_and_block!(attacker)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: attacker)
    game.settle!
  end

  it "is a 2/1 that can't block" do
    expect([norin.power, norin.toughness]).to eq([2, 1])
    expect(norin.can_block?(bears)).to be(false)
  end

  it "may exile a blocked creature you control and play it from exile this turn" do
    attack_and_block!(bears)
    game.resolve_choice!
    game.settle!

    exiled = game.exile.cards.find { _1.name == "Grizzly Bears" }
    expect(exiled).not_to be_nil
    expect(p1.creatures).not_to include(bears)
    expect(game.play_permissions.permits?(exiled, p1)).to be(true)
  end

  it "does nothing if you decline" do
    attack_and_block!(bears)
    game.skip_choice!
    game.settle!

    expect(p1.creatures).to include(bears)
  end
end
