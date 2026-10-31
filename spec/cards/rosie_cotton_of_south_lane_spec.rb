# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RosieCottonOfSouthLane do
  include_context "two player game"

  def foods(player = p1) = player.permanents.select { _1.type?("Food") }

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  def make_food(owner = p1)
    Magic::Tokens::Food.new(game: game, owner: owner).resolve!
    game.settle!
  end

  context "alone" do
    let!(:rosie) { ResolvePermanent("Rosie Cotton Of South Lane", owner: p1) }

    it "is a 1/1 that creates a Food token when it enters" do
      expect([rosie.power, rosie.toughness]).to eq([1, 1])
      expect(foods.count).to eq(1)
    end

    it "has no counter target when Rosie is the only creature" do
      make_food

      expect(foods.count).to eq(2)
      expect(game.choices).to be_empty
      expect(counters(rosie)).to eq(0)
    end
  end

  context "with other creatures" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:rosie) { ResolvePermanent("Rosie Cotton Of South Lane", owner: p1) }

    # Rosie's own Food triggers her second ability as soon as she enters.
    it "counts the Food she creates on entering as a token you created" do
      expect(game.choices.first.choices).to contain_exactly(bears, other)

      game.resolve_choice!(target: other)

      expect(counters(other)).to eq(1)
      expect(counters(bears)).to eq(0)
    end

    context "after the entering Food is resolved" do
      before { game.resolve_choice!(target: other) }

      it "puts a +1/+1 counter on a chosen creature when you create a token" do
        make_food
        game.resolve_choice!(target: bears)

        expect(counters(bears)).to eq(1)
        expect(counters(other)).to eq(1)
      end

      it "cannot target Rosie herself" do
        make_food

        expect(game.choices.first.choices).to contain_exactly(bears, other)
        expect(game.choices.first.choices).not_to include(rosie)
        expect(counters(rosie)).to eq(0)
      end

      it "does nothing when an opponent creates a token" do
        make_food(p2)

        expect(game.choices).to be_empty
        expect(counters(bears) + counters(other)).to eq(1)
      end
    end
  end
end
