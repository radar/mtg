# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArnaKennerdSkycaptain do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:arna) { ResolvePermanent("Arna Kennerüd, Skycaptain", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!
  end

  def plus_counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "has flying and lifelink" do
    expect(arna).to be_flying
    expect(arna).to be_lifelink
  end

  it "doubles the counters on an attacking modified creature" do
    bears.add_counter(Magic::Counters::Plus1Plus1, amount: 2)
    game.settle!
    attack_with(bears)

    expect(plus_counters(bears)).to eq(4)
  end

  it "does nothing for an unmodified attacker" do
    attack_with(bears)

    expect(plus_counters(bears)).to eq(0)
    expect(bears.attachments).to be_empty
  end

  it "copies each nontoken attached Equipment" do
    gear = ResolvePermanent("Adventuring Gear", owner: p1)
    gear.attach_to!(bears)
    attack_with(bears)

    expect(bears.attachments.count).to eq(2)
    expect(bears.attachments.count(&:token?)).to eq(1)
  end
end
