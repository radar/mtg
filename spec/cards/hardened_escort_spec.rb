# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HardenedEscort do
  include_context "two player game"

  let!(:escort) { ResolvePermanent("Hardened Escort", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/4" do
    expect([escort.power, escort.toughness]).to eq([2, 4])
  end

  it "gives another target creature +1/+0 and indestructible when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: escort, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(bears.power).to eq(3)
    expect(bears).to be_indestructible
    expect(escort.power).to eq(2)
  end

  it "can't target itself" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: escort, target: p2)
    current_turn.attackers_declared!

    expect(game.choices.last.choices).not_to include(escort)
  end
end
