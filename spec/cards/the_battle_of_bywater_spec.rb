# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheBattleOfBywater do
  include_context "two player game"

  before { go_to_main_phase! }

  def foods = p1.permanents.select { _1.type?("Food") }

  def cast_it
    card = Card("The Battle of Bywater", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 3)
    p1.cast(card: card) { |a| a.pay_mana(generic: { white: 1 }, white: 2) }
    game.stack.resolve!
    game.tick!
  end

  it "destroys creatures with power 3 or greater, from both players" do
    mine = ResolvePermanent("Serra Angel", owner: p1)
    theirs = ResolvePermanent("Serra Angel", owner: p2)
    cast_it

    expect(mine.zone).to be_nil
    expect(theirs.zone).to be_nil
  end

  it "leaves creatures with power 2 or less" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_it

    expect(bears.zone).not_to be_nil
    expect(theirs.zone).not_to be_nil
  end

  it "creates a Food for each creature you control after the destruction" do
    ResolvePermanent("Serra Angel", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    cast_it

    expect(foods.count).to eq(2)
    expect(p2.permanents.count { _1.type?("Food") }).to eq(0)
  end

  it "creates no Food when you control no creatures" do
    ResolvePermanent("Serra Angel", owner: p1)
    cast_it

    expect(foods.count).to eq(0)
  end
end
