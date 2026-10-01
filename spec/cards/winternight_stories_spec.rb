# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WinternightStories do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Winternight Stories", owner: p1) }

  it "draws three cards, then discards two unless you discard a creature card" do
    p1.add_mana(blue: 3)
    expect { p1.cast(card: card) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }; game.stack.resolve! }
      .to change { p1.hand.cards.size }.by(3)

    discards = p1.hand.cards.first(2)
    expect { game.resolve_choice!(cards: discards) }.to change { p1.hand.cards.size }.by(-2)


    expect(p1.graveyard.cards).to include(*discards)
  end

  it "can be harmonized from the graveyard for {4}{U}, then is exiled" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(blue: 3)

    p1.cast(card: card, harmonize: true) do |a|
      a.harmonize_tap(bear)
      a.pay_mana(generic: { blue: 2 }, blue: 1)
    end
    game.stack.resolve!

    expect(card.zone).to be_exile
    expect(game.choices.last).to be_a(Magic::Choice::DiscardUnless)
  end
end
