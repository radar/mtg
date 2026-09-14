# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnexpectedWindfall do
  include_context "two player game"

  subject(:unexpected_windfall) { Card("Unexpected Windfall", owner: p1) }
  let!(:discard_fodder) { Card("Island", owner: p1) }

  before do
    p1.hand.add(unexpected_windfall)
    p1.hand.add(discard_fodder)
  end

  it "cannot be cast without discarding a card as an additional cost" do
    p1.add_mana(generic: 2, red: 2)
    expect do
      p1.cast(card: unexpected_windfall) do |action|
        action.pay_mana(generic: { generic: 2 }, red: 2)
      end
    end.to raise_error("Additional costs have not been paid")
  end

  it "discards a card as an additional cost, draws two cards, and creates two Treasure tokens" do
    library_count_before = p1.library.count

    p1.add_mana(generic: 2, red: 2)
    p1.cast(card: unexpected_windfall) do |action|
      action.pay_mana(generic: { generic: 2 }, red: 2)
      action.pay_discard(discard_fodder)
    end
    game.stack.resolve!

    expect(discard_fodder.zone).to be_graveyard
    expect(p1.library.count).to eq(library_count_before - 2)

    treasures = p1.permanents.by_name("Treasure")
    expect(treasures.count).to eq(2)
  end
end
