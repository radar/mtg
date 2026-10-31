# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReviveTheShire do
  include_context "two player game"

  let(:spell) { Card("Revive The Shire", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:island) { Card("Island", owner: p1) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def pay_and_target(target)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(target) }
  end

  def cast(target)
    p1.hand.add(spell)
    p1.add_mana(green: 2)
    pay_and_target(target)
    game.stack.resolve!
    game.settle!
  end

  before do
    go_to_main_phase!
    p1.graveyard.add(bears)
  end

  it "returns the target permanent card from your graveyard to your hand" do
    cast(bears)

    expect(bears.zone).to eq(p1.hand)
    expect(p1.graveyard.cards).not_to include(bears)
  end

  it "can return a land card" do
    p1.graveyard.add(island)
    cast(island)

    expect(island.zone).to eq(p1.hand)
  end

  it "creates a Food token" do
    cast(bears)

    expect(foods.count).to eq(1)
    expect(p2.permanents.select { _1.type?("Food") }).to be_empty
  end

  it "cannot target a nonpermanent card in your graveyard" do
    instant = Card("Fungal Rebirth", owner: p1)
    p1.graveyard.add(instant)
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    expect { pay_and_target(instant) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "cannot target a card in an opponent's graveyard" do
    theirs = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(theirs)
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    expect { pay_and_target(theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "is a sorcery, castable only in a main phase" do
    current_turn.end!
    p1.hand.add(spell)
    p1.add_mana(green: 2)

    expect { pay_and_target(bears) }.to raise_error(Magic::IllegalAction, /only be cast at sorcery speed/)
  end
end
