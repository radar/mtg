# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FieryInscription do
  include_context "two player game"

  subject(:fiery_inscription) { ResolvePermanent("Fiery Inscription", owner: p1) }

  it "is an enchantment" do
    expect(fiery_inscription.enchantment?).to eq(true)
  end

  it "tempts the Ring when it enters" do
    fiery_inscription

    emblem = game.ring_emblem_for(p1)
    expect(emblem).not_to be_nil
    expect(emblem.level).to eq(1)
  end

  it "makes the controller choose a creature they control as their Ring-bearer" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    elephant = ResolvePermanent("Elvish Warmaster", owner: p1)

    fiery_inscription

    expect(game.choices.last).to be_a(Magic::Choice::RingBearer)
    game.resolve_choice!(target: bear)

    expect(p1.ring_bearer).to eq(bear)
    expect(bear).to be_ring_bearer
    expect(elephant).not_to be_ring_bearer
  end

  it "automatically becomes the Ring-bearer when it's the controller's only creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)

    fiery_inscription

    expect(p1.ring_bearer).to eq(bear)
    expect(bear).to be_ring_bearer
  end

  it "does not present a Ring-bearer choice without a creature" do
    fiery_inscription

    expect(game.choices).to be_empty
  end

  context "whenever the controller casts an instant or sorcery spell" do
    let(:bolt) { Card("Lightning Bolt", owner: p1) }

    before do
      fiery_inscription
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
    end

    it "deals 2 damage to each opponent" do
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
      game.stack.resolve!

      expect(p2.life).to eq(15)
    end
  end

  it "does not trigger on an opponent's instant or sorcery cast" do
    fiery_inscription

    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)

    p2.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p1) }
    game.stack.resolve!

    expect(p1.life).to eq(17)
  end
end
