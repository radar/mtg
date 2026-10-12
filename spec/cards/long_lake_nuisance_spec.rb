# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LongLakeNuisance do
  include_context "two player game"

  it "is a 3/1 flier" do
    bird = ResolvePermanent("Long Lake Nuisance", owner: p1)
    game.skip_choice! while game.choices.any?
    expect(bird.power).to eq(3)
    expect(bird.keywords).to include(Magic::Cards::Keywords::FLYING)
  end

  it "recruits: discarding a nonland card makes a Human Soldier" do
    ResolvePermanent("Long Lake Nuisance", owner: p1)
    spell = p1.hand.cards.find { !_1.land? } || Card("Long Lake Nuisance", owner: p1).tap { p1.hand.add(_1) }
    game.resolve_choice!(card: spell)
    expect(p1.creatures.map(&:name)).to include("Human Soldier")
  end

  it "recruits: discarding a land makes no token" do
    ResolvePermanent("Long Lake Nuisance", owner: p1)
    land = p1.hand.cards.find(&:land?)
    game.resolve_choice!(card: land)
    expect(p1.creatures.map(&:name)).not_to include("Human Soldier")
  end
end
