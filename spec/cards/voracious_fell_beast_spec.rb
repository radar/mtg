# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VoraciousFellBeast do
  include_context "two player game"

  before { go_to_main_phase! }

  def foods(player) = player.permanents.select { _1.type?("Food") }

  def cast_beast
    beast = Card("Voracious Fell Beast", owner: p1)
    p1.hand.add(beast)
    p1.add_mana(black: 6)
    p1.cast(card: beast) { |a| a.pay_mana(generic: { black: 4 }, black: 2) }
    game.stack.resolve!
    game.settle!
    beast
  end

  it "is a 4/4 flier" do
    beast = ResolvePermanent("Voracious Fell Beast", owner: p1)

    expect([beast.power, beast.toughness]).to eq([4, 4])
    expect(beast).to have_keyword(:flying)
  end

  it "makes the opponent sacrifice their only creature and creates a Food for you" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_beast

    expect(theirs.zone).to be_nil
    expect(foods(p1).count).to eq(1)
    expect(foods(p2).count).to eq(0)
  end

  it "lets the opponent choose which creature to sacrifice" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    angel = ResolvePermanent("Serra Angel", owner: p2)
    cast_beast
    game.resolve_choice!(target: angel)

    expect(angel.zone).to be_nil
    expect(bears.zone).not_to be_nil
    expect(foods(p1).count).to eq(1)
  end

  it "does not make you sacrifice your own creatures" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    cast_beast

    expect(mine.zone).not_to be_nil
  end

  it "creates no Food when the opponent has no creature" do
    cast_beast

    expect(foods(p1).count).to eq(0)
  end

  it "sacrifices the first creature if the choice is skipped" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Serra Angel", owner: p2)
    cast_beast
    game.skip_choice!

    expect(p2.creatures.count).to eq(1)
    expect(foods(p1).count).to eq(1)
  end
end
