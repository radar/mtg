# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GhostfireSlice do
  include_context "two player game"

  let(:slice) { Card("Ghostfire Slice", owner: p1) }

  before { p1.hand.add(slice) }

  it "is a colorless instant" do
    expect(slice.colors).to be_empty
    expect(slice.type?("Instant")).to be(true)
  end

  it "deals 4 damage to a player at full cost {2}{R}" do
    p1.add_mana(red: 3)
    p1.cast(card: slice) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!

    expect(p2.life).to eq(16)
  end

  it "deals 4 damage to a creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 3)
    p1.cast(card: slice) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.targeting(bear)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards).to include(bear.card)
  end

  it "costs {2} less if an opponent controls a multicolored permanent" do
    ResolvePermanent("Enigma Drake", owner: p2)
    p1.add_mana(red: 1)
    p1.cast(card: slice) do |action|
      action.pay_mana(red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!

    expect(p2.life).to eq(16)
  end

  it "does not cost less for a monocolored opposing permanent" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 1)

    expect do
      p1.cast(card: slice) do |action|
        action.pay_mana(red: 1)
        action.targeting(p2)
      end
    end.to raise_error(Magic::Costs::Mana::CannotPay)
  end

  it "does not cost less for your own multicolored permanent" do
    ResolvePermanent("Enigma Drake", owner: p1)
    p1.add_mana(red: 1)

    expect do
      p1.cast(card: slice) do |action|
        action.pay_mana(red: 1)
        action.targeting(p2)
      end
    end.to raise_error(Magic::Costs::Mana::CannotPay)
  end
end
