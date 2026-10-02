# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrimevalBounty do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bounty) { ResolvePermanent("Primeval Bounty", owner: p1) }

  it "creates a 3/3 green Beast token whenever you cast a creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
    beast = p1.creatures.find { _1.name == "Beast" }

    expect([beast.power, beast.toughness]).to eq([3, 3])
  end

  it "puts three +1/+1 counters on target creature you control whenever you cast a noncreature spell" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 1)
    p1.cast(card: Card("Boltwave", owner: p1)) { |a| a.pay_mana(red: 1) }
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([5, 5])
  end

  it "gains you 3 life whenever a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!

    expect(p1.life).to eq(23)
  end

  it "doesn't trigger on an opponent's spells" do
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 1)
    p2.cast(card: Card("Boltwave", owner: p2)) { |a| a.pay_mana(red: 1) }
    game.settle!

    expect(p1.creatures.select { _1.name == "Beast" }).to be_empty
  end
end
