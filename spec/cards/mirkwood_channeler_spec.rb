# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirkwoodChanneler do
  include_context "two player game"

  let!(:channeler) { ResolvePermanent("Mirkwood Channeler", owner: p1) }
  let!(:elf) { ResolvePermanent("Llanowar Elves", owner: p1) }

  it "is a 3/3" do
    expect([channeler.power, channeler.toughness]).to eq([3, 3])
  end

  it "gives a chosen Elf trample and +X/+X for X Forests at the beginning of combat on your turn" do
    3.times { ResolvePermanent("Forest", owner: p1) }
    ResolvePermanent("Island", owner: p1)
    skip_to_combat!
    expect(game.choices.first.choices).to contain_exactly(channeler, elf)

    game.resolve_choice!(target: elf)
    game.tick!

    expect([elf.power, elf.toughness]).to eq([4, 4])
    expect(elf).to have_keyword(:trample)
    expect([channeler.power, channeler.toughness]).to eq([3, 3])
    expect(channeler).not_to have_keyword(:trample)
  end

  it "can target the Channeler itself" do
    2.times { ResolvePermanent("Forest", owner: p1) }
    skip_to_combat!
    game.resolve_choice!(target: channeler)
    game.tick!

    expect([channeler.power, channeler.toughness]).to eq([5, 5])
    expect(channeler).to have_keyword(:trample)
  end

  it "gives +0/+0 with no Forests, but still trample" do
    skip_to_combat!
    game.resolve_choice!(target: elf)
    game.tick!

    expect([elf.power, elf.toughness]).to eq([1, 1])
    expect(elf).to have_keyword(:trample)
  end

  it "does not count an opponent's Forests" do
    ResolvePermanent("Forest", owner: p2)
    skip_to_combat!
    game.resolve_choice!(target: elf)
    game.tick!

    expect([elf.power, elf.toughness]).to eq([1, 1])
  end

  it "does not offer non-Elf creatures or the opponent's Elves" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    enemy_elf = ResolvePermanent("Llanowar Elves", owner: p2)
    skip_to_combat!

    expect(game.choices.first.choices).not_to include(bears, enemy_elf)
  end

  it "can still target its controller's own hexproof Elf" do
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Dive Down", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(elf) }
    game.stack.resolve!
    game.tick!
    expect(elf).to be_hexproof

    skip_to_combat!
    expect(game.choices.first.choices).to contain_exactly(channeler, elf)
  end

  it "still buffs a legal Elf when the mandatory choice is skipped" do
    ResolvePermanent("Forest", owner: p1)
    skip_to_combat!
    game.skip_choice!
    game.tick!

    expect([channeler, elf].count { _1.has_keyword?(:trample) }).to eq(1)
  end

  it "loses the bonus at end of turn" do
    ResolvePermanent("Forest", owner: p1)
    skip_to_combat!
    game.resolve_choice!(target: elf)
    game.tick!
    expect(elf.power).to eq(2)

    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(elf.power).to eq(1)
    expect(elf).not_to have_keyword(:trample)
  end

  it "does not trigger at the beginning of the opponent's combat" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!

    expect(game.choices).to be_empty
  end
end
