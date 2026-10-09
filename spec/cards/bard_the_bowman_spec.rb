# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BardTheBowman do
  include_context "two player game"

  let!(:bard) { ResolvePermanent("Bard The Bowman", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def draws_this_turn = current_turn.events.count { |e| e.is_a?(Magic::Events::CardDraw) && e.player == p1 }

  it "is a 1/3 with reach" do
    expect([bard.power, bard.toughness]).to eq([1, 3])
    expect(bard.reach?).to be(true)
  end

  it "puts a +1/+1 counter and lifelink on target creature when you draw your second card each turn" do
    go_to_main_phase!
    expect(draws_this_turn).to eq(1)
    expect(game.choices).to be_empty

    p1.draw!
    game.settle!
    game.resolve_choice!(target: bears) if game.choices.any?
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears.lifelink?).to be(true)
  end

  it "does not trigger on the third card" do
    go_to_main_phase!
    p1.draw!
    game.settle!
    game.resolve_choice!(target: bears) if game.choices.any?
    game.settle!
    p1.draw!
    game.settle!

    expect(game.choices).to be_empty
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end
end
