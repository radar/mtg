# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArchfiendsVessel do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 1/1 lifelink Human Cleric" do
    vessel = ResolvePermanent("Archfiend's Vessel", owner: p1)
    game.settle!

    expect([vessel.power, vessel.toughness]).to eq([1, 1])
    expect(vessel).to be_lifelink
  end

  it "stays on the battlefield when cast from your hand" do
    card = Card("Archfiend's Vessel", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 1)
    p1.cast(card:) { |a| a.pay_mana(black: 1) }
    game.stack.resolve!
    game.settle!

    expect(card.zone).to be_battlefield
    expect(p1.creatures.by_name("Demon")).to be_empty
  end

  it "is exiled for a 5/5 flying Demon when it enters from your graveyard" do
    card = Card("Archfiend's Vessel", owner: p1)
    p1.graveyard.add(card)
    Magic::Permanent.resolve(game:, card:, from_zone: card.zone, cast: false)
    game.settle!

    demon = p1.creatures.by_name("Demon").first
    expect(card.zone).to be_exile
    expect([demon.power, demon.toughness]).to eq([5, 5])
    expect(demon).to be_flying
  end
end
