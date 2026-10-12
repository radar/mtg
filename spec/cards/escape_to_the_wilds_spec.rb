# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EscapeToTheWilds do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Escape To The Wilds", owner: p1) }

  def cast_it
    p1.add_mana(red: 3, green: 2)
    p1.hand.add(card)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 2, green: 1 }, red: 1, green: 1) }
    game.stack.resolve!
  end

  it "exiles the top five cards, which you may play until the end of your next turn" do
    top = p1.library.first(5)
    cast_it

    expect(top).to all(satisfy { |c| c.zone.exile? })
    expect(top.map { |c| game.play_permissions.permits?(c, p1) }).to all(be_truthy)
  end

  it "lets you play an additional land this turn" do
    cast_it

    expect(p1.max_lands_per_turn).to eq(2)
  end
end
