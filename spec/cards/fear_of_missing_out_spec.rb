# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfMissingOut do
  include_context "two player game"

  def fill_graveyard!
    ["Grizzly Bears", "Forest", "Lightning Bolt", "World Map"].each { p1.graveyard.add(Card(_1, owner: p1)) }
  end

  def attack!(fear)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: fear, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/3 Enchantment Creature — Nightmare" do
    fear = ResolvePermanent("Fear of Missing Out", owner: p1)

    expect([fear.power, fear.toughness]).to eq([2, 3])
    expect(fear.type?("Enchantment")).to be(true)
    expect(fear.type?("Nightmare")).to be(true)
  end

  it "discards a card, then draws a card when it enters" do
    go_to_main_phase!
    discarded = p1.hand.cards.first
    hand_size = p1.hand.count
    ResolvePermanent("Fear of Missing Out", owner: p1, settle: false)
    game.settle!
    game.resolve_choice!(card: discarded)

    expect(discarded.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand_size)
  end

  context "when attacking" do
    let!(:fear) { ResolvePermanent("Fear of Missing Out", owner: p1) }
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before { game.skip_choice! if game.choices.any? }

    it "does nothing without delirium" do
      attack!(fear)

      expect(current_turn.additional_combat_pending?).to be(false)
    end

    it "with delirium untaps a creature and queues an additional combat phase" do
      fill_graveyard!
      bear.tap!
      attack!(fear)
      game.resolve_choice!(target: bear)

      expect(bear).not_to be_tapped
      expect(current_turn.additional_combat_pending?).to be(true)
    end
  end
end
