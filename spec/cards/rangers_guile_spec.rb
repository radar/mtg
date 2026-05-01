# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::RangersGuile do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "gives target creature you control +1/+1 and hexproof until end of turn" do
    p1.add_mana(green: 1)
    p1.cast(card: Card("Ranger's Guile")) do
      _1.auto_pay_mana
      _1.targeting(wood_elves)
    end

    game.stack.resolve!
    game.tick!

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
    expect(wood_elves.hexproof?).to eq(true)
    expect(wood_elves.keyword_grant_modifiers.first.until_eot?).to eq(true)
  end

  it "the +1/+1 boost and hexproof wear off after end of turn" do
    p1.add_mana(green: 1)
    p1.cast(card: Card("Ranger's Guile")) do
      _1.auto_pay_mana
      _1.targeting(wood_elves)
    end

    game.stack.resolve!
    game.tick!

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
    expect(wood_elves.hexproof?).to eq(true)

    game.current_turn.end!
    game.current_turn.cleanup!
    game.next_turn
    game.tick!

    expect(wood_elves.power).to eq(1)
    expect(wood_elves.toughness).to eq(1)
    expect(wood_elves.hexproof?).to eq(false)
  end
end
