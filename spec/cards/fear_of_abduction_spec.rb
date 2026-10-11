# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfAbduction do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Fear Of Abduction", owner: p1).tap { p1.hand.add(_1) } }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:fear) { p1.permanents.find { _1.card == card } }

  def cast!(exiling: mine)
    p1.add_mana(white: 6)
    p1.cast(card: card) { _1.pay_mana(generic: { white: 4 }, white: 2).pay_additional_cost(Magic::Costs::ExileCreature, exiling) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 5/5 flying Nightmare enchantment creature" do
    cast!

    expect([fear.power, fear.toughness]).to eq([5, 5])
    expect(fear).to have_keyword(:flying)
    expect(fear.card).to be_enchantment
  end

  it "exiles a creature you control as it is cast" do
    cast!

    expect(mine.card.zone).to be_exile
  end

  it "can't exile a creature you don't control" do
    expect { cast!(exiling: theirs) }.to raise_error(ArgumentError)
  end

  it "exiles target creature an opponent controls when it enters" do
    cast!

    expect(theirs.zone).to be_nil
    expect(theirs.card.zone).to be_exile
  end

  it "puts each card exiled with it into its owner's hand when it leaves the battlefield" do
    cast!
    fear.destroy!
    game.settle!

    expect(mine.card.zone).to be_hand
    expect(theirs.card.zone).to be_hand
    expect(mine.card.owner.hand.cards).to include(mine.card)
  end

  it "doesn't return a token that was exiled for the cost" do
    token = Magic::Cards::MidnightMayhem::GremlinToken.new(game: game, owner: p1).resolve!
    cast!(exiling: token)
    fear.destroy!
    game.settle!

    expect(p1.hand.cards.map(&:name)).not_to include("Gremlin")
  end
end
