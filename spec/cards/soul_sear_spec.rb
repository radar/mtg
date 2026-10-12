# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SoulSear do
  include_context "two player game"

  def cast(target)
    card = Card("Soul Sear", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "deals 5 damage to a creature" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p2) # 5/5
    cast(angel)

    expect(angel.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "makes an indestructible creature lose indestructible so it dies" do
    siege_striker = ResolvePermanent("Siege Striker", owner: p2)
    siege_striker.modify_base_toughness(5)
    game.tick!
    expect(siege_striker).to be_indestructible

    cast(siege_striker)

    expect(siege_striker.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "only removes indestructible until end of turn" do
    brash = ResolvePermanent("Brash Taunter", owner: p2)
    brash.modify_base_toughness(9)
    game.tick!
    cast(brash)
    expect(brash).not_to be_indestructible

    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(brash).to be_indestructible
  end
end
