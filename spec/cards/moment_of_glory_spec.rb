# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MomentOfGlory do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Moment Of Glory", owner: p1) }
  let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }
  let!(:other) { ResolvePermanent("Large Bear", owner: p1) }
  let!(:enemy) { ResolvePermanent("Large Bear", owner: p2) }

  it "puts a +1/+1 counter on target creature you control" do
    p1.hand.add(card)
    p1.add_mana(white: 1)
    p1.cast(card:) { |a| a.targeting(bear).pay_mana(white: 1) }
    game.stack.resolve!
    expect(bear.power).to eq(6)
    expect(other.power).to eq(5)
    expect(card.zone).to be_graveyard
  end

  it "from the graveyard also buffs each other creature you control, then is exiled" do
    p1.graveyard.add(card)
    p1.add_mana(white: 5)
    p1.cast(card:, flashback: true) { |a| a.targeting(bear).pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!
    expect(bear.power).to eq(6)
    expect(other.power).to eq(6)
    expect(enemy.power).to eq(5)
    expect(card.zone).to be_exile
  end
end
