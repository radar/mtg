# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BanishFromEdoras do
  include_context "two player game"

  let(:card) { Card("Banish From Edoras", owner: p1) }
  let!(:bear) { ResolvePermanent("Large Bear", owner: p2) }

  before do
    go_to_main_phase!
    p1.hand.add(card)
  end

  it "exiles target creature for its full cost" do
    p1.add_mana(white: 5)
    p1.cast(card:) { |a| a.targeting(bear).pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!
    game.settle!

    expect(bear.card.zone).to be_exile
    expect(game.battlefield.permanents).not_to include(bear)
    expect(p2.graveyard.cards).to be_empty
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "costs {2} less when it targets a tapped creature" do
    bear.tap!
    p1.add_mana(white: 3)
    p1.cast(card:) { |a| a.targeting(bear).pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.settle!

    expect(bear.card.zone).to be_exile
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "does not get cheaper against an untapped creature" do
    p1.add_mana(white: 3)
    expect do
      p1.cast(card:) { |a| a.targeting(bear).pay_mana(generic: { white: 2 }, white: 1) }
    end.to raise_error(StandardError)
    expect(game.battlefield.permanents).to include(bear)
  end

  it "can't be cast at instant speed" do
    theirs = Card("Banish From Edoras", owner: p2)
    p2.hand.add(theirs)
    p2.add_mana(white: 5)

    expect do
      p2.cast(card: theirs) { |a| a.targeting(bear).pay_mana(generic: { white: 4 }, white: 1) }
    end.to raise_error(Magic::IllegalAction, /sorcery speed/)
  end
end
