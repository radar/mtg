# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EntishRestoration do
  include_context "two player game"

  let(:forests) { Array.new(4) { Card("Forest", owner: p1) } }

  before do
    go_to_main_phase!
    forests.each { p1.library.add(_1) }
  end

  def cast_it
    p1.add_mana(green: 3)
    p1.cast(card: Card("Entish Restoration", owner: p1)) { _1.pay_mana(green: 1, generic: { green: 2 }) }
    game.stack.resolve!
  end

  it "sacrifices a land, then searches up to two basic lands onto the battlefield tapped" do
    sacrificed = ResolvePermanent("Plains", owner: p1)
    cast_it
    game.resolve_choice!(sacrifice: sacrificed)
    game.settle!

    expect(p1.lands).not_to include(sacrificed)
    expect(game.choices.last.upto).to eq(2)
    game.resolve_choice!(targets: forests.first(2))

    expect(p1.lands.map(&:card)).to include(*forests.first(2))
    expect(p1.lands.select(&:tapped?).size).to eq(2)
  end

  it "rejects searching for three without a creature of power 4 or more" do
    ResolvePermanent("Plains", owner: p1)
    cast_it
    game.resolve_choice!

    expect { game.resolve_choice!(targets: forests.first(3)) }.to raise_error(ArgumentError)
  end

  it "searches up to three with a creature of power 4 or greater" do
    ResolvePermanent("Plains", owner: p1)
    ResolvePermanent("Colossal Dreadmaw", owner: p1)
    game.tick!
    cast_it
    game.resolve_choice!
    expect(game.choices.last.upto).to eq(3)
    game.resolve_choice!(targets: forests.first(3))

    expect(p1.lands.map(&:card)).to include(*forests.first(3))
    expect(p1.lands.select(&:tapped?).size).to eq(3)
  end

  it "does not count an opponent's big creature" do
    ResolvePermanent("Plains", owner: p1)
    ResolvePermanent("Colossal Dreadmaw", owner: p2)
    game.tick!
    cast_it
    game.resolve_choice!

    expect(game.choices.last.upto).to eq(2)
  end

  it "makes the sacrifice mandatory" do
    plains = ResolvePermanent("Plains", owner: p1)
    cast_it
    game.skip_choice!

    expect(p1.lands).not_to include(plains)
    expect(game.choices.last.upto).to eq(2)
  end

  it "still searches when there is no land to sacrifice" do
    cast_it

    expect(game.choices.size).to eq(1)
    expect(game.choices.last.upto).to eq(2)
  end

  it "is an instant" do
    expect(Card("Entish Restoration").type?("Instant")).to be(true)
  end
end
