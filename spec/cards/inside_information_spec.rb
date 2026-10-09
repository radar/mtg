# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InsideInformation do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Inside Information", owner: p1) }
  let(:bear_card) { Card("Large Bear", owner: p2) }

  before do
    p1.hand.add(card)
    p2.library.add(bear_card)
  end

  def cast_inside_information(x)
    p1.add_mana(black: 2 + x)
    p1.cast(card:, value_for_x: x) { |a| a.targeting(p2).pay_mana(black: 2, x: { black: x }) }
    game.stack.resolve!
  end

  it "exiles the top X cards of the opponent's library" do
    expect { cast_inside_information(2) }.to change { p2.library.count }.by(-2)
    expect(bear_card.zone).to be_exile
  end

  it "lets you cast an exiled spell by paying life equal to its mana value" do
    cast_inside_information(1)
    expect { p1.cast(card: bear_card) }.to change { p1.life }.by(-5)
    game.stack.resolve!
    expect(p1.permanents.map(&:name)).to include("Large Bear")
  end

  it "does not let you play the exiled cards after this turn" do
    cast_inside_information(1)
    2.times { game.next_turn }
    go_to_main_phase!
    expect(bear_card.zone).to be_exile
    expect(game.play_permissions.permits?(bear_card, p1)).to eq(false)
  end
end
