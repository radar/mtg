# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FangedFlames do
  include_context "two player game"

  let(:flames) { Card("Fanged Flames", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(flames)
    p1.add_mana(red: 2)
  end

  def cast_at(target)
    p1.cast(card: flames) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a colorless sorcery" do
    expect(flames.colors).to be_empty
    expect(flames.type?("Sorcery")).to be(true)
  end

  it "deals 4 damage to a creature and exiles it if it dies" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_at(bear)

    expect(game.exile.cards).to include(bear.card)
    expect(p2.graveyard.cards).not_to include(bear.card)
  end

  it "leaves a creature that survives alone" do
    bear = ResolvePermanent("Ordinary Bear", owner: p2)
    cast_at(bear)

    expect(p2.creatures).to include(bear)
    expect(game.exile.cards).not_to include(bear.card)
  end

  it "deals 4 damage to a planeswalker" do
    chandra = ResolvePermanent("Chandra, Heart Of Fire", owner: p2)
    cast_at(chandra)

    expect(chandra.loyalty).to eq(1)
  end

  it "exiles a planeswalker that dies from the damage" do
    basri = ResolvePermanent("Basri Ket", owner: p2)
    cast_at(basri)

    expect(game.exile.cards).to include(basri.card)
    expect(p2.graveyard.cards).not_to include(basri.card)
  end

  it "exiles a survivor that dies later the same turn" do
    bear = ResolvePermanent("Ordinary Bear", owner: p2)
    cast_at(bear)
    bear.destroy!
    game.settle!

    expect(game.exile.cards).to include(bear.card)
    expect(p2.graveyard.cards).not_to include(bear.card)
  end

  it "stops exiling after the turn ends" do
    bear = ResolvePermanent("Ordinary Bear", owner: p2)
    cast_at(bear)
    current_turn.end!
    current_turn.cleanup!
    bear.destroy!
    game.settle!

    expect(p2.graveyard.cards).to include(bear.card)
    expect(game.exile.cards).not_to include(bear.card)
  end

  it "does not allow players as targets" do
    expect(flames.target_choices).not_to include(p2)
  end
end
