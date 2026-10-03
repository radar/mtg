# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WildbornPreserver do
  include_context "two player game"

  let!(:preserver) { ResolvePermanent("Wildborn Preserver", owner: p1) }

  it "is a 2/2 Elf Archer with flash and reach" do
    expect([preserver.power, preserver.toughness]).to eq([2, 2])
    expect(preserver).to be_reach
    expect(preserver.card.flash?).to be(true)
  end

  it "may pay X to put X +1/+1 counters on itself when another non-Human creature you control enters" do
    p1.add_mana(green: 2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.resolve_choice!(x: 2)
    game.tick!

    expect(preserver.counters.count).to eq(2)
    expect(preserver.power).to eq(4)
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "can pay less than all of the available mana" do
    p1.add_mana(green: 3)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.resolve_choice!(x: 1)

    expect(preserver.counters.count).to eq(1)
  end

  it "does nothing when declined" do
    p1.add_mana(green: 2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.skip_choice!

    expect(preserver.counters.count).to eq(0)
  end

  it "offers nothing when you have no mana" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
  end

  it "ignores Humans" do
    p1.add_mana(green: 2)
    ResolvePermanent("Storm Fleet Spy", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
  end

  it "ignores creatures the opponent controls" do
    p1.add_mana(green: 2)
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!

    expect(game.choices).to be_empty
  end

  it "ignores itself entering" do
    p1.add_mana(green: 2)
    ResolvePermanent("Wildborn Preserver", owner: p1)
    game.settle!

    # The first Preserver sees the second enter (another non-Human creature), not the second itself.
    expect(game.choices.size).to eq(1)
  end
end
