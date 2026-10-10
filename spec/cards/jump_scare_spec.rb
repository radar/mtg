# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JumpScare do
  include_context "two player game"

  subject { Card("Jump Scare") }

  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }

  before do
    p1.add_mana(white: 1)
    game.take_action(cast_action(player: p1, card: subject).pay_mana(white: 1).targeting(elves))
    game.stack.resolve!
    game.tick!
  end

  it "gives +2/+2, flying, and Horror enchantment creature types" do
    expect(elves.power).to eq(3)
    expect(elves.toughness).to eq(3)
    expect(elves).to have_keyword(Magic::Cards::Keywords::FLYING)
    expect(elves.type?("Horror")).to eq(true)
    expect(elves.enchantment?).to eq(true)
    expect(elves.creature?).to eq(true)
  end

  it "wears off at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(elves.power).to eq(1)
    expect(elves.enchantment?).to eq(false)
    expect(elves).not_to have_keyword(Magic::Cards::Keywords::FLYING)
  end
end
