# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BattlesongBerserker do
  include_context "two player game"

  let!(:berserker) { ResolvePermanent("Battlesong Berserker", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 3/4" do
    expect([berserker.power, berserker.toughness]).to eq([3, 4])
  end

  it "gives target creature +1/+0 and menace when you attack" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(berserker, target: p2)
    current_turn.attackers_declared!
    game.resolve_choice!(target: bears)
    game.settle!
    game.tick!

    expect(bears.power).to eq(3)
    expect(bears).to be_menace
  end
end
