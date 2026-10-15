# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ConsumingCorruption do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_at(target)
    p1.add_mana(black: 2)
    p1.cast(card: Card("Consuming Corruption", owner: p1)) { |a| a.pay_mana(black: 2).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "deals damage equal to your Swamps to a creature and gains that much life" do
    2.times { ResolvePermanent("Swamp", owner: p1) }
    life = p1.life

    cast_at(bear)

    expect(bear.damage).to eq(2)
    expect(p1.life).to eq(life + 2)
  end

  it "counts only Swamps you control" do
    ResolvePermanent("Swamp", owner: p1)
    3.times { ResolvePermanent("Swamp", owner: p2) }
    ResolvePermanent("Forest", owner: p1)
    life = p1.life

    cast_at(bear)

    expect(bear.damage).to eq(1)
    expect(p1.life).to eq(life + 1)
  end

  it "deals and gains nothing with no Swamps" do
    life = p1.life

    cast_at(bear)

    expect(bear.damage).to eq(0)
    expect(p1.life).to eq(life)
  end

  it "can target a planeswalker" do
    walker = ResolvePermanent("Jaya Ballard", owner: p2)
    loyalty = walker.loyalty
    2.times { ResolvePermanent("Swamp", owner: p1) }

    cast_at(walker)

    expect(walker.loyalty).to eq(loyalty - 2)
  end

  it "can't target a player" do
    p1.add_mana(black: 2)

    expect { p1.cast(card: Card("Consuming Corruption", owner: p1)) { |a| a.pay_mana(black: 2).targeting(p2) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target a creature with hexproof" do
    big_bear = ResolvePermanent("Gigantic Big Bear", owner: p2)
    p1.add_mana(black: 2)

    expect { p1.cast(card: Card("Consuming Corruption", owner: p1)) { |a| a.pay_mana(black: 2).targeting(big_bear) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
