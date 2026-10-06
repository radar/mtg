# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrudicladTelchorEngineer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:brudiclad) { ResolvePermanent("Brudiclad, Telchor Engineer", owner: p1) }

  def tokens(player = p1) = player.creatures.select(&:token?)

  def beginning_of_combat
    current_turn.beginning_of_combat!
    game.settle!
  end

  it "is a legendary 4/4 artifact creature" do
    expect([brudiclad.power, brudiclad.toughness]).to eq([4, 4])
    expect(brudiclad.legendary?).to be true
    expect(brudiclad.type?("Artifact")).to be true
  end

  it "gives creature tokens you control haste" do
    token = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!
    game.tick!

    expect(token).to have_keyword(:haste)
  end

  it "doesn't give nontoken creatures or an opponent's tokens haste" do
    theirs = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p2).resolve!
    game.tick!

    expect(brudiclad).not_to have_keyword(:haste)
    expect(theirs).not_to have_keyword(:haste)
  end

  it "creates a 2/1 blue Phyrexian Myr artifact creature token at the beginning of combat on your turn" do
    beginning_of_combat

    expect(tokens.count).to eq(1)
    myr = tokens.first
    expect(myr.name).to eq("Phyrexian Myr")
    expect([myr.power, myr.toughness]).to eq([2, 1])
    expect(myr.colors).to eq([:blue])
    expect(myr.type?("Artifact")).to be true
    expect(game.choices).to be_empty
  end

  it "may make each other token a copy of a chosen token" do
    goblin = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!
    beginning_of_combat

    choice = game.choices.last
    expect(choice).to be_a(described_class::CopyChoice)
    myr = tokens.find { _1.name == "Phyrexian Myr" }
    game.resolve_choice!(target: myr)
    game.tick!

    expect(goblin.name).to eq("Phyrexian Myr")
    expect([goblin.power, goblin.toughness]).to eq([2, 1])
    expect(goblin.type?("Artifact")).to be true
  end

  it "may decline to copy" do
    goblin = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!
    beginning_of_combat
    game.skip_choice!

    expect(goblin.name).to eq("Goblin")
  end

  it "doesn't copy onto the opponent's tokens" do
    theirs = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p2).resolve!
    beginning_of_combat

    expect(theirs.name).to eq("Goblin")
  end

  it "doesn't trigger on the opponent's turn" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    game.settle!

    expect(tokens).to be_empty
  end
end
