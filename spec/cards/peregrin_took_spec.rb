# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PeregrinTook do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:peregrin) { ResolvePermanent("Peregrin Took", owner: p1) }

  def foods(player) = player.permanents.select { _1.type?("Food") }

  def treasures(player) = player.permanents.select { _1.type?("Treasure") }

  def make_token(source, token_class)
    source.trigger_effect(:create_token, token_class: token_class)
    game.settle!
  end

  it "adds a Food to tokens you create" do
    make_token(peregrin, Magic::Tokens::Treasure)

    expect(treasures(p1).count).to eq(1)
    expect(foods(p1).count).to eq(1)
  end

  it "adds one Food for a group of tokens" do
    peregrin.trigger_effect(:create_token, token_class: Magic::Tokens::Treasure, amount: 3)
    game.settle!

    expect(treasures(p1).count).to eq(3)
    expect(foods(p1).count).to eq(1)
  end

  it "makes two Foods when the token is a Food" do
    make_token(peregrin, Magic::Tokens::Food)

    expect(foods(p1).count).to eq(2)
  end

  it "does not affect tokens an opponent creates" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    make_token(theirs, Magic::Tokens::Treasure)

    expect(treasures(p2).count).to eq(1)
    expect(foods(p2).count).to eq(0)
    expect(foods(p1).count).to eq(0)
  end

  context "Sacrifice three Foods" do
    def ability = peregrin.activated_abilities.first

    def make_foods(count)
      count.times.map { Magic::Tokens::Food.new(game: game, owner: p1).resolve! }
    end

    it "draws a card" do
      food = make_foods(3)
      expect { p1.activate_ability(ability: ability) { |a| a.pay_sacrifice(food) }; game.stack.resolve!; game.tick! }
        .to change { p1.hand.count }.by(1)
      expect(foods(p1).count).to eq(0)
    end

    it "cannot be paid with fewer than three Foods" do
      make_foods(2)

      expect(ability.costs.first.can_pay?(p1)).to be(false)
    end

    it "rejects sacrificing only two Foods" do
      food = make_foods(3)

      expect { p1.activate_ability(ability: ability) { |a| a.pay_sacrifice(food.first(2)) } }
        .to raise_error(RuntimeError, /Sacrifice exactly three/)
    end
  end
end
