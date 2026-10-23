# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InfernalCaptor do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p2) }
  let!(:sol_ring) { ResolvePermanent("Sol Ring", owner: p2) }

  def enter_captor
    ResolvePermanent("Infernal Captor", owner: p1)
  end

  it "is a 3/3" do
    captor = enter_captor
    expect([captor.power, captor.toughness]).to eq([3, 3])
  end

  it "does nothing more when exploit is declined" do
    enter_captor
    game.skip_choice!
    game.settle!

    expect(game.choices).to be_empty
    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "steals a creature, untaps it and gives it haste when it exploits" do
    dreadmaw.tap!
    enter_captor
    game.resolve_choice!(sacrifice: bears)
    game.resolve_choice!(target: dreadmaw)
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(dreadmaw.controller).to eq(p1)
    expect(dreadmaw.tapped?).to eq(false)
    expect(dreadmaw.has_keyword?(Magic::Cards::Keywords::HASTE)).to eq(true)
  end

  it "can steal an artifact" do
    enter_captor
    game.resolve_choice!(sacrifice: bears)
    game.resolve_choice!(target: sol_ring)
    game.settle!

    expect(sol_ring.controller).to eq(p1)
  end

  it "returns the permanent at end of turn" do
    enter_captor
    game.resolve_choice!(sacrifice: bears)
    game.resolve_choice!(target: dreadmaw)
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    game.settle!

    expect(dreadmaw.controller).to eq(p2)
  end
end
