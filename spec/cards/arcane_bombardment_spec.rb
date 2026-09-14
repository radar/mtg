# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArcaneBombardment do
  include_context "two player game"

  let!(:arcane_bombardment) { ResolvePermanent("Arcane Bombardment", owner: p1) }
  let(:old_bolt) { Card("Lightning Bolt", owner: p1) }
  let(:shock) { Card("Shock", owner: p1) }

  before do
    p1.graveyard.add(old_bolt)
    p1.hand.add(shock)
    p1.add_mana(red: 1)
  end

  it "exiles an instant or sorcery card at random from the graveyard and offers a free copy of it" do
    p1.cast(card: shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }

    expect(old_bolt.zone).to be_exile
    expect(arcane_bombardment.exiled_cards).to include(old_bolt)

    game.resolve_choice!
    game.resolve_choice!(target: p2)
    game.stack.resolve!

    expect(p2.life).to eq(20 - 2 - 3)
  end

  it "does nothing when the graveyard has no instant or sorcery cards" do
    p1.graveyard.remove(old_bolt)

    p1.cast(card: shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(game.choices).to be_empty
    expect(arcane_bombardment.exiled_cards).to be_empty
  end

  it "only triggers on the first instant or sorcery spell cast each turn" do
    other_shock = Card("Shock", owner: p1)
    other_bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(other_shock)
    p1.graveyard.add(other_bolt)
    p1.add_mana(red: 1)

    p1.cast(card: shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.resolve_choice!
    game.resolve_choice!(target: p2)
    game.stack.resolve!

    p1.cast(card: other_shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(arcane_bombardment.exiled_cards).to eq([old_bolt])
    expect(game.choices).to be_empty
  end

  it "can decline to cast the free copy" do
    p1.cast(card: shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }

    game.skip_choice!
    game.stack.resolve!

    expect(p2.life).to eq(20 - 2)
  end
end
