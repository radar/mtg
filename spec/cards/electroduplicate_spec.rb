# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Electroduplicate do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Electroduplicate", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast(target, flashback: false)
    p1.hand.add(card) unless flashback
    p1.add_mana(red: 4)
    if flashback
      p1.cast(card:, flashback: true) { |a| a.pay_mana(generic: { red: 2 }, red: 2).targeting(target) }
    else
      p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, red: 1).targeting(target) }
    end
    game.stack.resolve!
    game.settle!
  end

  def copies = p1.creatures.select { _1.name == "Grizzly Bears" && _1.token? }

  it "creates a hasty token copy of target creature you control" do
    cast(bears)

    expect(copies.size).to eq(1)
    expect([copies.first.power, copies.first.toughness]).to eq([2, 2])
    expect(copies.first.haste?).to eq(true)
    expect(bears.haste?).to eq(false)
  end

  it "sacrifices the token at the beginning of the end step" do
    cast(bears)
    current_turn.end!
    game.settle!

    expect(copies).to be_empty
    expect(p1.creatures).to include(bears)
  end

  it "can't target an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.hand.add(card)
    p1.add_mana(red: 3)

    expect { p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, red: 1).targeting(theirs) } }.to raise_error(StandardError)
  end

  it "can be cast again from the graveyard with flashback for {2}{R}{R}" do
    cast(bears)
    game.stack.resolve!
    expect(card.zone).to be_a(Magic::Zones::Graveyard)

    cast(bears, flashback: true)

    expect(copies.size).to eq(2)
    expect(card.zone).to be_a(Magic::Zones::Exile).or be_nil
  end
end
