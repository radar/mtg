# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EldraziLinebreaker do
  include_context "two player game"

  let!(:linebreaker) { ResolvePermanent("Eldrazi Linebreaker", owner: p1) }
  # With a single legal target the choice resolves itself, so there are always two creatures.
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def begin_combat(player)
    game.notify!(Magic::Events::BeginningOfCombat.new(active_player: player))
    game.settle!
  end

  it "is a devoid 3/3 trampler with {C} in its cost" do
    expect(linebreaker.colors).to be_empty
    expect([linebreaker.power, linebreaker.toughness]).to eq([3, 3])
    expect(linebreaker.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to be(true)
    expect(Card("Eldrazi Linebreaker", owner: p1).cost.cost).to include(colorless: 1)
  end

  it "gives a target creature haste and +X/+0, X being your Eldrazi, at the beginning of combat on your turn" do
    ResolvePermanent("Basking Broodscale", owner: p1)
    ResolvePermanent("Basking Broodscale", owner: p2)
    begin_combat(p1)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears.power).to eq(4)
    expect(bears.has_keyword?(Magic::Cards::Keywords::HASTE)).to be(true)
  end

  it "counts only Eldrazi at resolution, so Linebreaker alone gives +1" do
    begin_combat(p1)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears.power).to eq(3)
  end

  it "can target itself" do
    begin_combat(p1)
    game.resolve_choice!(target: linebreaker)
    game.tick!

    expect(linebreaker.power).to eq(4)
  end

  it "takes the first creature if the choice is skipped" do
    begin_combat(p1)
    game.skip_choice!
    game.tick!

    expect(game.choices).to be_empty
    expect(linebreaker.power + bears.power).to eq(6)
  end

  it "does not offer an opponent's creature as a target" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    begin_combat(p1)

    expect(game.choices.first.choices).to contain_exactly(linebreaker, bears)
    expect(game.choices.first.choices).not_to include(theirs)
  end

  it "wears off at end of turn" do
    begin_combat(p1)
    game.resolve_choice!(target: bears)
    game.tick!
    expect(bears.power).to eq(3)

    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears.power).to eq(2)
    expect(bears.has_keyword?(Magic::Cards::Keywords::HASTE)).to be(false)
  end

  it "doesn't trigger on an opponent's turn" do
    begin_combat(p2)

    expect(game.choices).to be_empty
  end
end
