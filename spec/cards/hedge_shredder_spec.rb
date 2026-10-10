# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HedgeShredder do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:shredder) { ResolvePermanent("Hedge Shredder", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack!
    p1.activate_ability(ability: shredder.activated_abilities.first) { |a| a.pay_multi_tap([bears]) }
    game.stack.resolve!
    game.tick!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(shredder, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def stack_library!(*names)
    names.reverse_each { p1.library.add(Card(_1, owner: p1)) }
  end

  it "is a 5/5 Vehicle with crew 1" do
    expect(shredder).to be_artifact
    expect(shredder).not_to be_creature
    attack!
    expect([shredder.power, shredder.toughness]).to eq([5, 5])
  end

  it "may mill two cards when it attacks" do
    stack_library!("Lightning Bolt", "Shock")
    attack!
    game.resolve_choice!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to eq(%w[Shock Lightning\ Bolt])
  end

  it "mills nothing when you decline" do
    attack!
    game.skip_choice!
    game.settle!

    expect(p1.graveyard.cards).to be_empty
  end

  it "puts milled land cards onto the battlefield tapped" do
    stack_library!("Forest", "Lightning Bolt")
    attack!
    game.resolve_choice!
    game.settle!
    game.stack.resolve!
    game.settle!

    forest = p1.permanents.by_name("Forest").first
    expect(forest).to be_tapped
    expect(p1.graveyard.cards.map(&:name)).to eq(["Lightning Bolt"])
  end
end
