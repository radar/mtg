# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheEaglesAreComing do
  include_context "two player game"

  let(:card) { Card("The Eagles Are Coming!", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:pegasus) { ResolvePermanent("Concordia Pegasus", owner: p1) }

  before { p1.hand.add(card) }

  def birds = p1.creatures.select { _1.type?("Bird") }

  def next_upkeep
    game.next_turn
    current_turn.untap!
    current_turn.upkeep!
    game.settle!
  end

  it "returns one target creature you own to your hand" do
    p1.add_mana(white: 2)
    p1.cast(card:) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.card.zone).to be_hand
    expect(game.battlefield.permanents).to include(pegasus)
  end

  it "creates a 4/4 flying Bird Soldier at the beginning of the next upkeep per creature returned" do
    p1.add_mana(white: 2)
    p1.cast(card:) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!
    expect(birds).to be_empty
    next_upkeep

    expect(birds.count).to eq(1)
    expect([birds.first.power, birds.first.toughness]).to eq([4, 4])
    expect(birds.first).to have_keyword(:flying)
  end

  it "when kicked, returns any number of your creatures and makes a Bird for each" do
    p1.add_mana(white: 6)
    p1.cast(card:) do
      _1.pay_kicker(generic: { white: 2 }, white: 2)
      _1.pay_mana(generic: { white: 1 }, white: 1)
      _1.targeting(bears, pegasus)
    end
    game.stack.resolve!
    next_upkeep

    expect(bears.card.zone).to be_hand
    expect(pegasus.card.zone).to be_hand
    expect(birds.count).to eq(2)
  end

  it "only creates tokens once" do
    p1.add_mana(white: 2)
    p1.cast(card:) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!
    next_upkeep
    next_upkeep

    expect(birds.count).to eq(1)
  end
end
