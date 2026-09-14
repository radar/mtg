# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoggFanatic do
  include_context "two player game"

  subject(:fanatic) { ResolvePermanent("Mogg Fanatic", owner: p1) }

  it "is a 1/1 Goblin" do
    expect(fanatic.power).to eq(1)
    expect(fanatic.toughness).to eq(1)
    expect(fanatic.types).to include("Goblin")
  end

  it "deals 1 damage to any target when sacrificed" do
    p1.activate_ability(ability: fanatic.activated_abilities.first) do |a|
      a.targeting(p2)
    end
    game.stack.resolve!

    expect(p2.life).to eq(19)
    expect(fanatic.zone).to be_nil
  end
end
