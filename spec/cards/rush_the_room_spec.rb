# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RushTheRoom do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Rush The Room", owner: p1) }
  let(:first_strike) { Magic::Cards::Keywords::FIRST_STRIKE }
  let(:haste) { Magic::Cards::Keywords::HASTE }

  def cast_on(target)
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card: card) do |a|
      a.pay_mana(red: 1)
      a.targeting(target)
    end
    game.stack.resolve!
    game.tick!
  end

  it "gives a non-Goblin, non-Orc +1/+0 and first strike but not haste" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    cast_on(bear)
    expect([bear.power, bear.toughness]).to eq([3, 2])
    expect(bear.has_keyword?(first_strike)).to eq(true)
    expect(bear.has_keyword?(haste)).to eq(false)
    expect(card.zone).to eq(p1.graveyard)
  end

  it "also gives a Goblin haste" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1, summoning_sick: true)
    expect(goblin.has_keyword?(haste)).to eq(false)
    cast_on(goblin)
    expect(goblin.power).to eq(2)
    expect(goblin.has_keyword?(first_strike)).to eq(true)
    expect(goblin.has_keyword?(haste)).to eq(true)
  end

  it "also gives an Orc haste" do
    orc = ResolvePermanent("Warg Rider", owner: p1, summoning_sick: true)
    cast_on(orc)
    expect(orc.has_keyword?(first_strike)).to eq(true)
    expect(orc.has_keyword?(haste)).to eq(true)
  end

  it "can target an opponent's creature" do
    theirs = ResolvePermanent("Goblin Arsonist", owner: p2)
    cast_on(theirs)
    expect(theirs.has_keyword?(first_strike)).to eq(true)
    expect(theirs.has_keyword?(haste)).to eq(true)
  end

  it "wears off at end of turn" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    cast_on(goblin)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(goblin.power).to eq(1)
    expect(goblin.has_keyword?(first_strike)).to eq(false)
    expect(goblin.has_keyword?(haste)).to eq(false)
  end

  it "cannot target a hexproof creature an opponent controls" do
    big = ResolvePermanent("Gigantic Big Bear", owner: p2)
    p1.hand.add(card)
    p1.add_mana(red: 1)
    expect do
      p1.cast(card: card) do |a|
        a.pay_mana(red: 1)
        a.targeting(big)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
