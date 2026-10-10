# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfFalling do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:fear) { ResolvePermanent("Fear Of Falling", owner: p1) }

  it "is a 4/4 flying Enchantment Creature" do
    expect([fear.power, fear.toughness]).to eq([4, 4])
    expect(fear).to be_flying
    expect(fear).to be_enchantment
  end

  it "gives a defending creature -2/-0 and removes flying until your next turn" do
    flyer = ResolvePermanent("Shacklegeist", owner: p2) # 2/2 flying
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(fear, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(flyer.power).to eq(0)
    expect(flyer).not_to be_flying

    game.next_turn # the opponent's turn
    go_to_main_phase!
    expect(flyer.power).to eq(0)
    expect(flyer).not_to be_flying

    game.next_turn # your turn: the effect ends as it begins
    go_to_main_phase!
    expect(flyer.power).to eq(2)
    expect(flyer).to be_flying
  end
end
