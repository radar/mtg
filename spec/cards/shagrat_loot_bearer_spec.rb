# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShagratLootBearer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:shagrat) { ResolvePermanent("Shagrat, Loot Bearer", owner: p1) }

  def armies = p1.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  def equipment(owner: p1)
    ResolvePermanent("Cranial Ram", owner: owner).tap { game.settle! }
  end

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary 4/4 Orc Soldier" do
    expect([shagrat.power, shagrat.toughness]).to eq([4, 4])
    expect(shagrat.type?("Orc")).to eq(true)
    expect(shagrat.type?("Soldier")).to eq(true)
    expect(shagrat.legendary?).to eq(true)
  end

  it "makes no usable Army when attacking with no Equipment attached (X = 0)" do
    attack_with(shagrat)
    expect(game.choices).to be_empty
    expect(armies).to be_empty
  end

  it "attaches the chosen Equipment and amasses Orcs 1" do
    ram = equipment
    attack_with(shagrat)
    game.resolve_choice!(target: ram)
    game.settle!
    expect(ram.attached_to).to eq(shagrat)
    expect(shagrat.attachments).to include(ram)
    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(1)
    expect(armies.first.type?("Orc")).to eq(true)
  end

  it "offers each Equipment as a target and attaches the chosen one" do
    ram1 = equipment
    ram2 = equipment
    attack_with(shagrat)
    expect(game.choices.last.choices).to contain_exactly(ram1, ram2)
    game.resolve_choice!(target: ram2)
    game.settle!
    expect(ram2.attached_to).to eq(shagrat)
    expect(ram1.attached_to).not_to eq(shagrat)
    expect(counters(armies.first)).to eq(1)
  end

  it "counts Equipment already attached to Shagrat, so declining still amasses" do
    ram1 = equipment
    ram2 = equipment
    ram1.attach_to!(shagrat)
    attack_with(shagrat)
    game.skip_choice!
    game.settle!
    expect(ram2.attached_to).not_to eq(shagrat)
    expect(counters(armies.first)).to eq(1)
  end

  it "amasses X equal to all attached Equipment after the new attach" do
    ram1 = equipment
    ram2 = equipment
    ram1.attach_to!(shagrat)
    attack_with(shagrat)
    game.resolve_choice!(target: ram2)
    game.settle!
    expect(counters(armies.first)).to eq(2)
  end

  it "can attach an opponent's Equipment without changing its control" do
    ram = equipment(owner: p2)
    attack_with(shagrat)
    game.resolve_choice!(target: ram)
    game.settle!
    expect(ram.attached_to).to eq(shagrat)
    expect(ram.controller).to eq(p2)
    expect(counters(armies.first)).to eq(1)
  end

  it "does not trigger when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ram = equipment
    germ = ram.attached_to # Cranial Ram's living weapon attaches it to its Germ
    expect(germ).not_to be_nil
    attack_with(bears)
    expect(game.choices).to be_empty
    expect(ram.attached_to).to eq(germ)
    expect(armies).to be_empty
  end
end
