# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeirloomAuntie do
  include_context "two player game"

  let!(:auntie) { ResolvePermanent("Heirloom Auntie", owner: p1) }

  it "is a 4/4 goblin warlock that enters with two -1/-1 counters" do
    expect(auntie.card.types).to include("Goblin", "Warlock")
    expect(auntie.power).to eq(2)
    expect(auntie.toughness).to eq(2)
    expect(auntie.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "surveils 1 and removes a -1/-1 counter when another creature you control dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.library.add(Card("Forest", owner: p1))
    bears.destroy!
    game.settle!

    game.resolve_choice!

    expect(auntie.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end

  it "does not remove a counter it doesn't have" do
    2.times do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.library.add(Card("Forest", owner: p1))
      bears.destroy!
      game.settle!
      game.resolve_choice!
    end

    expect(auntie.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)

    third_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.library.add(Card("Forest", owner: p1))
    third_bears.destroy!
    game.settle!
    game.resolve_choice!

    expect(auntie.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
  end

  it "does not trigger for itself dying" do
    auntie.destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
