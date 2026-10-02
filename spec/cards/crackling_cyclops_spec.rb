# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CracklingCyclops do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:cyclops) { ResolvePermanent("Crackling Cyclops", owner: p1) }

  it "is a 0/4" do
    expect([cyclops.power, cyclops.toughness]).to eq([0, 4])
  end

  it "gets +3/+0 until end of turn when you cast a noncreature spell" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Boltwave", owner: p1)) { |a| a.pay_mana(red: 1) }
    game.settle!
    game.tick!

    expect(cyclops.power).to eq(3)
  end

  it "doesn't trigger on a creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
    game.tick!

    expect(cyclops.power).to eq(0)
  end
end
