# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThorinsLastStand do
  include_context "two player game"

  let(:card) { Card("Thorin's Last Stand", owner: p1) }

  before do
    p1.hand.add(card)
    p1.add_mana(white: 4)
  end

  it "gives creatures you control +2/+1 but not the opponent's" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.cast(card: card) do |action|
      action.pay_mana(generic: { white: 2 }, white: 2)
      action.choose_mode(described_class::Mode1)
    end
    game.stack.resolve!
    game.tick!

    expect([mine.power, mine.toughness]).to eq([4, 3])
    expect([theirs.power, theirs.toughness]).to eq([2, 2])
  end

  it "destroys an artifact or enchantment and gains 2 life" do
    artifact = ResolvePermanent("Mind Stone", owner: p2)
    p1.cast(card: card) do |action|
      action.pay_mana(generic: { white: 2 }, white: 2)
      action.choose_mode(described_class::Mode2) { _1.targeting(artifact) }
    end
    game.stack.resolve!

    expect(artifact.card.zone).to be_graveyard
    expect(p1.life).to eq(22)
  end
end
