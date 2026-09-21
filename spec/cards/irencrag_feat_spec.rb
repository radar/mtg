# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IrencragFeat do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:irencrag_feat) { Card("Irencrag Feat", owner: p1) }

  def cast_irencrag_feat!
    p1.hand.add(irencrag_feat)
    p1.add_mana(red: 4)
    p1.cast(card: irencrag_feat) { |a| a.pay_mana(generic: { red: 1 }, red: 3) }
    game.stack.resolve!
  end

  it "adds seven red mana" do
    cast_irencrag_feat!

    expect(p1.mana_pool[:red]).to eq(7)
  end

  it "allows one more spell to be cast this turn" do
    cast_irencrag_feat!

    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)

    expect {
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    }.not_to raise_error
  end

  it "prevents casting a second additional spell this turn" do
    cast_irencrag_feat!

    first_bolt = Card("Lightning Bolt", owner: p1)
    second_bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(first_bolt)
    p1.hand.add(second_bolt)

    p1.cast(card: first_bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect {
      p1.cast(card: second_bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    }.to raise_error(Magic::IllegalAction, /cannot cast any more spells/)
  end

  it "expires at the start of the next turn" do
    cast_irencrag_feat!
    game.next_turn

    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)

    expect {
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    }.not_to raise_error
  end
end
