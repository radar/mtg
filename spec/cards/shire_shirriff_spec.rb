# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShireShirriff do
  include_context "two player game"

  let!(:enemy_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:enemy_ox) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def make_token
    Magic::Tokens::Treasure.new(game: game, owner: p1).resolve!
    game.settle!
    p1.permanents.find { _1.type?("Treasure") }
  end

  def shirriff = p1.permanents.find { _1.name == "Shire Shirriff" }

  it "is a 2/2 with vigilance" do
    s = ResolvePermanent("Shire Shirriff", owner: p1)

    expect([s.power, s.toughness]).to eq([2, 2])
    expect(s).to have_keyword(:vigilance)
  end

  it "offers nothing when you control no token" do
    ResolvePermanent("Shire Shirriff", owner: p1)

    expect(game.choices).to be_empty
    expect(p2.creatures.count).to eq(2)
  end

  it "does not offer a nontoken creature to sacrifice" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Shire Shirriff", owner: p1)

    expect(game.choices).to be_empty
  end

  it "exiles a chosen opposing creature after sacrificing a token" do
    token = make_token
    ResolvePermanent("Shire Shirriff", owner: p1)
    expect(game.choices.first.candidates).to eq([token])

    game.resolve_choice!(sacrifice: token)
    expect(p1.permanents).not_to include(token)
    expect(game.choices.first.choices).to contain_exactly(enemy_bears, enemy_ox)

    game.resolve_choice!(target: enemy_bears)
    game.settle!

    expect(p2.creatures).to contain_exactly(enemy_ox)
    expect(enemy_bears.card.zone).to be_exile
  end

  it "does nothing if the sacrifice is declined" do
    token = make_token
    ResolvePermanent("Shire Shirriff", owner: p1)
    game.skip_choice!
    game.settle!

    expect(p1.permanents).to include(token)
    expect(p2.creatures.count).to eq(2)
    expect(game.choices).to be_empty
  end

  it "never targets its own side's creatures" do
    token = make_token
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Shire Shirriff", owner: p1)
    game.resolve_choice!(sacrifice: token)

    expect(game.choices.first.choices).not_to include(mine)
  end

  it "does not offer a hexproof creature" do
    p2.add_mana(blue: 1)
    p2.cast(card: Card("Dive Down", owner: p2)) { |a| a.pay_mana(blue: 1).targeting(enemy_bears) }
    game.stack.resolve!
    game.tick!
    expect(enemy_bears).to be_hexproof

    token = make_token
    ResolvePermanent("Shire Shirriff", owner: p1)
    game.resolve_choice!(sacrifice: token)
    game.settle!

    # The only legal target auto-resolves; the hexproof creature is untouched.
    expect(p2.creatures).to contain_exactly(enemy_bears)
    expect(enemy_ox.card.zone).to be_exile
  end

  it "picks a legal target when the mandatory exile choice is skipped" do
    token = make_token
    ResolvePermanent("Shire Shirriff", owner: p1)
    game.resolve_choice!(sacrifice: token)
    game.skip_choice!
    game.settle!

    expect(p2.creatures.count).to eq(1)
  end

  it "exiles nothing if the Shirriff left the battlefield before the trigger resolved" do
    token = make_token
    s = ResolvePermanent("Shire Shirriff", owner: p1)
    s.destroy!
    game.settle!

    game.resolve_choice!(sacrifice: token)
    game.resolve_choice!(target: enemy_bears) if game.choices.any?
    game.settle!

    expect(p1.permanents).not_to include(token)
    expect(p2.creatures).to contain_exactly(enemy_bears, enemy_ox)
    expect(game.exile.cards).to be_empty
  end

  it "returns the exiled creature when the Shirriff leaves the battlefield" do
    token = make_token
    s = ResolvePermanent("Shire Shirriff", owner: p1)
    game.resolve_choice!(sacrifice: token)
    game.resolve_choice!(target: enemy_bears)
    game.settle!
    expect(p2.creatures.count).to eq(1)

    s.destroy!
    game.settle!

    expect(p2.creatures.count).to eq(2)
    expect(p2.creatures.map(&:name)).to eq(["Grizzly Bears", "Grizzly Bears"])
    expect(p2.creatures).not_to include(enemy_bears)
    expect(game.exile.cards).to be_empty
  end
end
