# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThodenKingOfRohan do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:enemy_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def enter_theoden
    permanent = ResolvePermanent("Thoden King Of Rohan", owner: p1)
    game.settle!
    permanent
  end

  it "is a legendary 2/3 Human Noble" do
    card = Card("Thoden King Of Rohan")
    expect(card).to be_legendary
    expect([card.base_power, card.base_toughness]).to eq([2, 3])
    expect(card.type?("Human")).to be(true)
    expect(card.type?("Noble")).to be(true)
  end

  it "triggers when Théoden enters and offers every creature as a target" do
    theoden = enter_theoden
    expect(game.choices.size).to eq(1)
    expect(game.choices.first.choices).to contain_exactly(bears, enemy_bears, theoden)
  end

  it "gives the chosen creature double strike, including an opponent's" do
    enter_theoden
    game.resolve_choice!(target: enemy_bears)
    game.tick!

    expect(enemy_bears).to be_double_strike
    expect(bears).not_to be_double_strike
  end

  it "triggers when another Human you control enters" do
    theoden = enter_theoden
    game.resolve_choice!(target: bears)
    game.settle!
    game.tick!

    # Protector of Gondor is a Human; so is its token, so there are two more triggers.
    ResolvePermanent("Protector Of Gondor", owner: p1)
    game.settle!
    expect(game.choices.size).to be >= 1
    game.resolve_choice!(target: theoden)
    game.settle!
    game.resolve_choice!(target: theoden) if game.choices.any?
    game.tick!
    expect(theoden).to be_double_strike
  end

  it "does not trigger when a non-Human enters" do
    enter_theoden
    game.resolve_choice!(target: bears)
    game.settle!
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    expect(game.choices).to be_empty
  end

  it "does not trigger when an opponent's Human enters" do
    enter_theoden
    game.resolve_choice!(target: bears)
    game.settle!
    ResolvePermanent("Protector Of Gondor", owner: p2)
    game.settle!
    expect(game.choices).to be_empty
  end

  it "still gives double strike to a legal creature when the choice is skipped (target is mandatory)" do
    enter_theoden
    game.skip_choice!
    game.tick!
    expect(game.choices).to be_empty
    expect([bears, enemy_bears].count(&:double_strike?)).to eq(1)
  end

  it "does not offer a hexproof creature" do
    p2.add_mana(blue: 1)
    p2.cast(card: Card("Dive Down", owner: p2)) { |a| a.pay_mana(blue: 1).targeting(enemy_bears) }
    game.stack.resolve!
    game.tick!
    expect(enemy_bears).to be_hexproof

    enter_theoden
    expect(game.choices.first.choices).not_to include(enemy_bears)
    expect(game.choices.first.choices).to include(bears)
  end

  it "loses double strike at end of turn" do
    enter_theoden
    game.resolve_choice!(target: bears)
    game.tick!
    expect(bears).to be_double_strike

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears).not_to be_double_strike
  end
end
