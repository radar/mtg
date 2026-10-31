# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HobbitsSting do
  include_context "two player game"

  def food(owner = p1) = Magic::Tokens::Food.new(game: game, owner: owner).resolve!

  let!(:small_victim) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:big_victim) { ResolvePermanent("Serra Angel", owner: p2) }
  let(:sting) { Card("Hobbit's Sting", owner: p1) }

  def cast_on(target)
    p1.add_mana(white: 2)
    p1.cast(card: sting) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "deals damage equal to creatures plus Foods you control" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    food
    cast_on(big_victim)

    expect(big_victim.damage).to eq(3)
  end

  it "does not count the opponent's creatures or Foods" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    food(p2)
    cast_on(big_victim)

    expect(big_victim.damage).to eq(1)
  end

  it "kills a creature when X is large enough" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    food
    cast_on(small_victim)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "deals no damage with no creatures or Foods" do
    cast_on(big_victim)

    expect(big_victim.damage).to eq(0)
  end
end
