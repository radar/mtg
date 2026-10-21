# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EtchedSlith do
  include_context "two player game"

  let!(:slith) { ResolvePermanent("Etched Slith", owner: p1) }

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def hit_player!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(slith, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 1/1 menace artifact Phyrexian Slith" do
    expect([slith.power, slith.toughness]).to eq([1, 1])
    expect(slith).to be_menace
    expect(slith.card).to be_artifact
    expect(slith.type?("Slith")).to be(true)
  end

  it "puts a +1/+1 counter on itself when it deals combat damage to a player" do
    hit_player!

    expect(plus_counters(slith)).to eq(1)
    expect(p2.life).to eq(19)
    expect(game.choices).to be_empty
  end

  it "may remove a counter from another permanent" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.add_counter("+1/+1")
    game.settle!
    hit_player!

    expect(game.choices.last.choices).to eq([bears])
    game.resolve_choice!(target: bears)
    expect(plus_counters(bears)).to eq(0)
  end

  it "does not offer itself, even though it now has a counter" do
    hit_player!
    expect(game.choices).to be_empty
  end

  it "may remove a counter from an opponent" do
    p2.add_counter("poison")
    hit_player!

    expect(game.choices.last.choices).to eq([p2])
    game.resolve_choice!(target: p2)
    expect(p2.counters.count).to eq(0)
  end

  it "removes nothing if the choice is declined" do
    p2.add_counter("poison")
    hit_player!
    game.skip_choice!

    expect(p2.counters.count).to eq(1)
  end

  it "asks which kind of counter when the target has several" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.add_counter("+1/+1")
    bears.add_counter("stun")
    game.settle!
    hit_player!
    game.resolve_choice!(target: bears)
    game.resolve_choice!(counter_type: Magic::Counters::Stun)

    expect(plus_counters(bears)).to eq(1)
    expect(bears.counters.of_type(Magic::Counters::Stun).count).to eq(0)
  end

  it "offers no choice if it left the battlefield before the trigger resolved" do
    p2.add_counter("poison")
    game.notify!(Magic::Events::CombatDamageDealt.new(source: slith, target: p2, damage: 1))
    slith.destroy!
    game.settle!

    expect(game.choices).to be_empty
    expect(slith.zone).to be_nil
    expect(p2.counters.count).to eq(1)
  end

  it "adds no counter when dealing combat damage to a creature" do
    blockers = 2.times.map { ResolvePermanent("Grizzly Bears", owner: p2) }
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(slith, target: p2)
    current_turn.attackers_declared!
    blockers.each { current_turn.declare_blocker(_1, attacker: slith) }
    go_to_combat_damage!
    game.settle!

    expect(plus_counters(slith)).to eq(0)
  end

  it "does not offer p1 as an opponent, but offers another permanent p1 controls with a counter" do
    p1.add_counter("poison")
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    mine.add_counter("+1/+1")
    game.settle!
    hit_player!

    expect(game.choices.last.choices).to eq([mine])
  end

  it "removes the first kind if the kind choice is skipped" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.add_counter("+1/+1")
    bears.add_counter("stun")
    game.settle!
    hit_player!
    game.resolve_choice!(target: bears)
    game.skip_choice!

    expect(bears.counters.count).to eq(1)
  end
end
