# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SerraAngel do
  include_context "two player game"

  it "is a 4/4 Angel with flying and vigilance" do
    angel = ResolvePermanent("Serra Angel", owner: p1)

    expect([angel.power, angel.toughness]).to eq([4, 4])
    expect(angel).to be_flying
    expect(angel).to be_vigilant
  end

  it "doesn't tap when it attacks" do
    angel = ResolvePermanent("Serra Angel", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(angel, target: p2)

    expect(angel).not_to be_tapped
  end
end
