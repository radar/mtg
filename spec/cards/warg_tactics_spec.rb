# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WargTactics do
  include_context "two player game"

  let(:card) { Card("Warg Tactics", owner: p1) }

  before do
    p1.hand.add(card)
    p1.add_mana(green: 2)
  end

  it "destroys a creature with flying" do
    flyer = ResolvePermanent("Concordia Pegasus", owner: p2)
    p1.cast(card: card) do |action|
      action.pay_mana(generic: { green: 1 }, green: 1)
      action.choose_mode(described_class::Mode1) { _1.targeting(flyer) }
    end
    game.stack.resolve!

    expect(flyer.card.zone).to be_graveyard
  end

  it "puts a +1/+1 counter and grants trample and hexproof" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.cast(card: card) do |action|
      action.pay_mana(generic: { green: 1 }, green: 1)
      action.choose_mode(described_class::Mode2) { _1.targeting(bears) }
    end
    game.stack.resolve!
    game.tick!

    expect(bears.power).to eq(3)
    expect(bears.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
    expect(bears.has_keyword?(Magic::Cards::Keywords::HEXPROOF)).to eq(true)
  end
end
