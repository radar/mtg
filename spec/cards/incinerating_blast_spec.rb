# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IncineratingBlast do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Fire Elemental", owner: p2) } # 5/4

  def cast_blast
    p1.add_mana(red: 5)
    p1.cast(card: Card("Incinerating Blast", owner: p1)) { |a| a.pay_mana(generic: { red: 4 }, red: 1).targeting(rival) }
    game.stack.resolve!
  end

  it "deals 6 damage to target creature" do
    cast_blast
    game.tick!

    expect(rival.card.zone).to be_graveyard
  end

  it "lets you discard a card to draw a card" do
    cast_blast
    hand_size = p1.hand.count
    discarded = p1.hand.first
    game.resolve_choice!
    game.resolve_choice!(card: discarded)

    expect(p1.hand.count).to eq(hand_size)
    expect(discarded.zone).to be_graveyard
  end

  it "does nothing more if you decline" do
    cast_blast
    hand_size = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand_size)
  end
end
