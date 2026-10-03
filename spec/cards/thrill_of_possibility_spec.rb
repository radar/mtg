# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrillOfPossibility do
  include_context "two player game"

  let(:thrill) { Card("Thrill of Possibility", owner: p1) }
  let!(:fodder) { Card("Island", owner: p1) }

  before do
    p1.hand.add(thrill)
    p1.hand.add(fodder)
  end

  it "cannot be cast without discarding a card as an additional cost" do
    p1.add_mana(red: 2)

    expect do
      p1.cast(card: thrill) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    end.to raise_error("Additional costs have not been paid")
  end

  it "discards a card as an additional cost, then draws two cards" do
    library_size = p1.library.count
    p1.add_mana(red: 2)
    p1.cast(card: thrill) { |a| a.pay_mana(generic: { red: 1 }, red: 1).pay_discard(fodder) }
    game.stack.resolve!

    expect(fodder.zone).to be_graveyard
    expect(p1.library.count).to eq(library_size - 2)
    expect(p1.hand).not_to include(fodder)
  end

  it "is an instant" do
    expect(thrill).to be_instant
  end
end
