# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrphansOfTheWheat do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:orphans) { ResolvePermanent("Orphans Of The Wheat", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(orphans, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/1 Human" do
    expect([orphans.power, orphans.toughness]).to eq([2, 1])
  end

  it "gets +1/+1 for each creature tapped this way" do
    a = ResolvePermanent("Grizzly Bears", owner: p1)
    b = ResolvePermanent("Grizzly Bears", owner: p1)
    c = ResolvePermanent("Grizzly Bears", owner: p1)
    attack!
    game.resolve_choice!(targets: [a, b])
    game.tick!

    expect([a, b]).to all(be_tapped)
    expect(c).not_to be_tapped
    expect([orphans.power, orphans.toughness]).to eq([4, 3])
  end

  it "may tap none" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    attack!
    game.resolve_choice!(targets: [])
    game.tick!

    expect([orphans.power, orphans.toughness]).to eq([2, 1])
  end

  it "has no choice without other untapped creatures" do
    attack!

    expect(game.choices).to be_empty
  end
end
