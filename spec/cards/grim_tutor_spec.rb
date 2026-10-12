# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrimTutor do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:target_card) { Card("Serra Angel", owner: p1) }

  before { p1.library.add(target_card) }

  def cast
    card = Card("Grim Tutor", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "searches your library for a card and puts it into your hand" do
    cast
    game.resolve_choice!(targets: [target_card])

    expect(target_card.zone).to be_hand
  end

  it "makes you lose 3 life" do
    cast
    game.resolve_choice!(targets: [target_card])

    expect(p1.life).to eq(17)
  end
end
