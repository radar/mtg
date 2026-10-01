# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnendingWhisper do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Unending Whisper", owner: p1) }

  it "draws a card" do
    p1.add_mana(blue: 1)

    expect { p1.cast(card: card) { |a| a.pay_mana(blue: 1) }; game.stack.resolve! }.to change { p1.hand.cards.size }.by(1)
    expect(card.zone).to be_graveyard
  end

  it "can be harmonized from the graveyard for {5}{U}, then is exiled" do
    p1.graveyard.add(card)
    p1.add_mana(blue: 6)

    expect { p1.cast(card: card, harmonize: true) { |a| a.pay_mana(generic: { blue: 5 }, blue: 1) }; game.stack.resolve! }
      .to change { p1.hand.cards.size }.by(1)
    expect(card.zone).to be_exile
  end

  it "is not offered from the graveyard until the harmonize cost can be paid" do
    p1.graveyard.add(card)
    harmonize_casts = -> { game.legal_actions(p1).grep(Magic::Actions::Cast).select { _1.card == card } }

    expect(harmonize_casts.call).to be_empty
    p1.add_mana(blue: 6)
    expect(harmonize_casts.call.size).to eq(1)
  end
end
