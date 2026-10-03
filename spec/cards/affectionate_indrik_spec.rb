# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AffectionateIndrik do
  include_context "two player game"

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:big_enemy) { ResolvePermanent("Serra Angel", owner: p2) }

  it "is a 4/4 Beast" do
    indrik = ResolvePermanent("Affectionate Indrik", owner: p1, settle: false)

    expect([indrik.power, indrik.toughness]).to eq([4, 4])
  end

  it "may fight a creature you don't control when it enters" do
    indrik = ResolvePermanent("Affectionate Indrik", owner: p1)
    game.settle!
    game.resolve_choice!
    game.resolve_choice!(target: enemy)
    game.settle!

    expect(enemy.card.zone).to be_graveyard
    expect(indrik.damage).to eq(2)
  end

  it "does not fight when declined" do
    indrik = ResolvePermanent("Affectionate Indrik", owner: p1)
    game.settle!
    game.skip_choice!

    expect(indrik.damage).to eq(0)
    expect(enemy.damage).to eq(0)
  end

  it "cannot fight your own creatures" do
    ResolvePermanent("Affectionate Indrik", owner: p1)
    game.settle!
    game.resolve_choice!

    expect(game.choices.last.choices.to_a).to contain_exactly(enemy, big_enemy)
  end
end
