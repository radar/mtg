# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoldAdder do
  include_context "two player game"

  let!(:adder) { ResolvePermanent("Mold Adder", owner: p1) }
  let!(:rival_creature) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def counters = adder.counters.of_type(Magic::Counters["+1/+1"]).count

  def cast_for_p2(card_name, mana)
    p2.add_mana(mana)
    yield p2.cast(card: Card(card_name, owner: p2)) { |a| a.pay_mana(mana).targeting(rival_creature) }
    game.settle!
  end

  it "is a 1/1 Fungus Snake" do
    expect([adder.power, adder.toughness]).to eq([1, 1])
  end

  it "may get a +1/+1 counter when an opponent casts a blue spell" do
    cast_for_p2("Dive Down", blue: 1) { }
    game.resolve_choice!
    game.tick!

    expect(counters).to eq(1)
  end

  it "may get a +1/+1 counter when an opponent casts a black spell" do
    cast_for_p2("Stab", black: 1) { }
    game.resolve_choice!
    game.tick!

    expect(counters).to eq(1)
  end

  it "gets nothing if you decline" do
    cast_for_p2("Stab", black: 1) { }
    game.skip_choice!

    expect(counters).to eq(0)
  end

  it "doesn't trigger on a red spell" do
    cast_for_p2("Kindled Fury", red: 1) { }

    expect(game.choices).to be_empty
    expect(counters).to eq(0)
  end

  it "doesn't trigger on your own blue spell" do
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Dive Down", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(adder) }
    game.settle!

    expect(game.choices).to be_empty
  end
end
