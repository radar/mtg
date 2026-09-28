# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AuntiesSentence do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Auntie's Sentence", owner: p1) }

  before { p1.hand.add(card) }

  it "reveals the opponent's hand and lets you choose a nonland permanent card for them to discard" do
    bears = Card("Grizzly Bears", owner: p2)
    forest = Card("Forest", owner: p2)
    p2.hand.add(bears)
    p2.hand.add(forest)
    p1.add_mana(black: 2)

    p1.cast(card:) do |a|
      a.pay_mana(generic: { black: 1 }, black: 1)
      a.choose_mode(described_class::RevealAndDiscard) { _1.targeting(p2) }
    end
    game.stack.resolve!

    game.resolve_choice!(target: bears)

    expect(bears.zone).to be_graveyard
    expect(forest.zone).to be_hand
  end

  it "gives target creature -2/-2 until end of turn instead" do
    berserker = ResolvePermanent("Boneclub Berserker", owner: p2) # 2/4, survives -2/-2
    p1.add_mana(black: 2)

    p1.cast(card:) do |a|
      a.pay_mana(generic: { black: 1 }, black: 1)
      a.choose_mode(described_class::MinusTwoMinusTwo) { _1.targeting(berserker) }
    end
    game.stack.resolve!

    expect(berserker.power).to eq(0)
    expect(berserker.toughness).to eq(2)
  end
end
