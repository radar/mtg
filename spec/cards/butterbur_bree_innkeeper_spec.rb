# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ButterburBreeInnkeeper do
  include_context "two player game"

  let!(:butterbur) { ResolvePermanent("Butterbur Bree Innkeeper", owner: p1) }

  def foods(player = p1) = player.permanents.select { _1.type?("Food") }

  def end_step!
    current_turn.end!
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/3" do
    expect([butterbur.power, butterbur.toughness]).to eq([3, 3])
  end

  it "creates a Food at your end step if you control none" do
    end_step!

    expect(foods.count).to eq(1)
  end

  it "does not create a Food if you already control one" do
    Magic::Tokens::Food.new(game: game, owner: p1).resolve!
    end_step!

    expect(foods.count).to eq(1)
  end

  it "does nothing at the opponent's end step" do
    game.next_turn
    go_to_main_phase!
    expect(game.current_turn.active_player).to eq(p2)
    end_step!

    expect(foods).to be_empty
  end

  it "does not count the opponent's Food" do
    Magic::Tokens::Food.new(game: game, owner: p2).resolve!
    end_step!

    expect(foods.count).to eq(1)
    expect(foods(p2).count).to eq(1)
  end
end
