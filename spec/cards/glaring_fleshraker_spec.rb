# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlaringFleshraker do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:fleshraker) { ResolvePermanent("Glaring Fleshraker", owner: p1) }

  def spawn_tokens = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a 2/2 Eldrazi Drone" do
    expect([fleshraker.power, fleshraker.toughness]).to eq([2, 2])
  end

  it "creates an Eldrazi Spawn when you cast a colorless spell" do
    colorless = Card("Glaring Fleshraker", owner: p1)
    p1.hand.add(colorless)
    p1.add_mana(colorless: 3)
    p1.cast(card: colorless) { |a| a.pay_mana(colorless: 1, generic: { colorless: 2 }) }
    game.settle!

    expect(spawn_tokens.size).to eq(1)
  end

  it "does not trigger on a coloured spell" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    p1.add_mana(green: 2)
    p1.cast(card: bears) { |a| a.pay_mana(green: 1, generic: { green: 1 }) }
    game.settle!

    expect(spawn_tokens).to be_empty
  end

  it "does not trigger on an opponent's colorless spell" do
    go_to_main_phase_for!(p2)
    colorless = Card("Glaring Fleshraker", owner: p2)
    p2.hand.add(colorless)
    p2.add_mana(colorless: 3)
    p2.cast(card: colorless) { |a| a.pay_mana(colorless: 1, generic: { colorless: 2 }) }
    game.settle!

    expect(spawn_tokens).to be_empty
  end

  it "deals 1 damage to each opponent when another colorless creature you control enters" do
    ResolvePermanent("Glaring Fleshraker", owner: p1)

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "does not ping for a coloured creature" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(p2.life).to eq(20)
  end

  it "does not ping for an opponent's colorless creature" do
    ResolvePermanent("Glaring Fleshraker", owner: p2)

    expect(p2.life).to eq(20)
  end

  it "pings for both the colorless creature spell and the colorless Spawn token it makes" do
    colorless = Card("Glaring Fleshraker", owner: p1)
    p1.hand.add(colorless)
    p1.add_mana(colorless: 3)
    p1.cast(card: colorless) { |a| a.pay_mana(colorless: 1, generic: { colorless: 2 }) }
    game.settle!

    expect(spawn_tokens.size).to eq(1)
    expect(p2.life).to eq(18)
  end
end
