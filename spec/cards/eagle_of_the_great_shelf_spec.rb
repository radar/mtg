# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EagleOfTheGreatShelf do
  include_context "two player game"

  let!(:eagle) { ResolvePermanent("Eagle Of The Great Shelf", owner: p1) }

  it "is a 2/5 flying Bird Soldier" do
    expect([eagle.power, eagle.toughness]).to eq([2, 5])
    expect(eagle.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
  end

  it "gets +1/+1 for each other creature you control when it attacks" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: eagle, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect([eagle.power, eagle.toughness]).to eq([4, 7])
  end
end
