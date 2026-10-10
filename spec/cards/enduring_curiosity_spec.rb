# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnduringCuriosity do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:curiosity) { ResolvePermanent("Enduring Curiosity", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 4/3 Enchantment Creature — Cat Glimmer with flash" do
    expect([curiosity.power, curiosity.toughness]).to eq([4, 3])
    expect(curiosity.type?("Enchantment")).to be(true)
    expect(curiosity.flash?).to be(true)
  end

  it "draws a card when a creature you control deals combat damage to a player" do
    expect { attack_with(bears) }.to change { p1.hand.count }.by(1)
  end

  it "draws for each creature that connects" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.declare_attacker(curiosity, target: p2)
    current_turn.attackers_declared!

    expect do
      go_to_combat_damage!
      game.settle!
    end.to change { p1.hand.count }.by(2)
  end

  it "does not draw when an opponent's creature deals combat damage" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.next_turn
    go_to_main_phase!
    opp_bears = p2.creatures.first
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(opp_bears, target: p1)
    current_turn.attackers_declared!

    expect do
      go_to_combat_damage!
      game.settle!
    end.not_to change { p1.hand.count }
  end

  it "returns as a non-creature enchantment when it dies" do
    curiosity.destroy!
    game.settle!

    returned = game.battlefield.cards.by_name("Enduring Curiosity").first
    expect(returned.creature?).to be(false)
    expect(returned.type?("Enchantment")).to be(true)
  end
end
