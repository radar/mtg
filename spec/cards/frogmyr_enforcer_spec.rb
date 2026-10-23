# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FrogmyrEnforcer do
  include_context "two player game"

  let(:card) { Card("Frogmyr Enforcer", owner: p1) }

  before { go_to_main_phase! }

  def permanent = p1.creatures.find { _1.name == "Frogmyr Enforcer" }

  it "is a colorless 4/4 cast for {7}" do
    p1.hand.add(card)
    p1.add_mana(green: 7)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 7 }) }
    game.stack.resolve!

    expect(permanent.power).to eq(4)
    expect(permanent.toughness).to eq(4)
    expect(permanent.colors).to be_empty
    expect(permanent.mana_value).to eq(7)
  end

  it "can be cast with prototype for {3}{R} as a red 2/2" do
    p1.hand.add(card)
    p1.add_mana(red: 1, green: 3)
    action = Magic::Actions::Cast::Prototyped.new(game: game, player: p1, card: card)
    action.pay_mana(generic: { green: 3 }, red: 1)
    game.take_action(action)
    game.stack.resolve!

    expect(permanent.power).to eq(2)
    expect(permanent.toughness).to eq(2)
    expect(permanent.colors).to eq([:red])
    expect(permanent.mana_value).to eq(4)
    expect(permanent.type?("Artifact")).to be(true)
  end

  it "costs {1} less for each artifact you control (affinity)" do
    2.times { ResolvePermanent("Rakdos Signet", owner: p1) }
    p1.hand.add(card)
    p1.add_mana(green: 5)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 5 }) }
    game.stack.resolve!

    expect(permanent).not_to be_nil
  end

  it "returns to full size after leaving the battlefield" do
    p1.hand.add(card)
    p1.add_mana(red: 1, green: 3)
    action = Magic::Actions::Cast::Prototyped.new(game: game, player: p1, card: card)
    action.pay_mana(generic: { green: 3 }, red: 1)
    game.take_action(action)
    game.stack.resolve!
    permanent.destroy!
    game.settle!

    expect(card.prototyped).to be(false)
    expect(card.colors).to be_empty
    expect(card.base_power).to eq(4)
  end
end
