# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrcishMedicine do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def army = p1.creatures.find { _1.type?("Army") }

  def cast
    card = Card("Orcish Medicine", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!
  end

  it "grants lifelink on that choice, not indestructible" do
    cast
    game.resolve_choice!(mode: :lifelink)
    game.tick!
    expect(bears).to be_lifelink
    expect(bears).not_to be_indestructible
  end

  it "grants indestructible on that choice, not lifelink" do
    cast
    game.resolve_choice!(mode: :indestructible)
    game.tick!
    expect(bears).to be_indestructible
    expect(bears).not_to be_lifelink
  end

  it "defaults to lifelink when the choice is skipped" do
    cast
    game.skip_choice!
    game.tick!
    expect(bears).to be_lifelink
  end

  it "wears off at end of turn" do
    cast
    game.resolve_choice!(mode: :indestructible)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears).not_to be_indestructible
  end

  it "amasses Orcs 1" do
    cast
    game.resolve_choice!(mode: :lifelink)
    game.tick!
    expect(army.type?("Orc")).to eq(true)
    expect([army.power, army.toughness]).to eq([1, 1])
    expect(p2.creatures.any? { _1.type?("Army") }).to eq(false)
  end

  it "adds to an existing Army" do
    cast
    game.resolve_choice!(mode: :lifelink)
    cast
    game.resolve_choice!(mode: :lifelink)
    game.tick!
    expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
    expect(army.power).to eq(2)
  end
end
