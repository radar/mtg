# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PippinsBravery do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Pippins Bravery", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def cast(target)
    p1.hand.add(spell)
    p1.add_mana(green: 1)
    p1.cast(card: spell) { |a| a.pay_mana(green: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  context "with no Food to sacrifice" do
    it "gives +2/+2 without asking" do
      cast(bears)

      expect(game.choices).to be_empty
      expect(bears.power).to eq(4)
      expect(bears.toughness).to eq(4)
    end
  end

  context "with a Food" do
    let!(:food) { Magic::Tokens::Food.new(game: game, owner: p1).resolve! }

    it "offers a choice and does not pump until it is answered" do
      cast(bears)

      expect(game.choices.first).to be_a(Magic::Cards::PippinsBravery::SacrificeFoodChoice)
      expect(bears.power).to eq(2)
    end

    it "gives +4/+4 and sacrifices the Food when you sacrifice" do
      cast(bears)
      game.resolve_choice!(sacrifice: food)
      game.settle!

      expect(bears.power).to eq(6)
      expect(bears.toughness).to eq(6)
      expect(foods).to be_empty
    end

    it "gives only +2/+2 and keeps the Food when you decline" do
      cast(bears)
      game.skip_choice!
      game.settle!

      expect(bears.power).to eq(4)
      expect(bears.toughness).to eq(4)
      expect(foods).to include(food)
    end

    it "does not pump other creatures" do
      cast(bears)
      game.resolve_choice!(sacrifice: food)
      game.settle!

      expect(other.power).to eq(2)
    end

    it "can target an opponent's creature" do
      cast(other)
      game.resolve_choice!(sacrifice: food)
      game.settle!

      expect(other.power).to eq(6)
    end

    it "refuses a sacrifice that is not one of your Foods" do
      cast(bears)

      expect { game.resolve_choice!(sacrifice: bears) }.to raise_error(ArgumentError)
      expect(bears.zone).to be_a(Magic::Zones::Battlefield)
    end

    it "wears off at end of turn" do
      cast(bears)
      game.resolve_choice!(sacrifice: food)
      current_turn.end!
      current_turn.cleanup!
      game.settle!

      expect(bears.power).to eq(2)
    end
  end

  it "only counts Foods, not other artifacts" do
    Magic::Tokens::Treasure.new(game: game, owner: p1).resolve!
    cast(bears)

    expect(game.choices).to be_empty
    expect(bears.power).to eq(4)
  end
end
