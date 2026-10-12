# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Wargling do
  include_context "two player game"

  let!(:wargling) { ResolvePermanent("Wargling", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "gets +1/+0 and gives creatures you control trample when you control a power 4 creature" do
    giant = ResolvePermanent("Axegrinder Giant", owner: p1)
    attack_with(wargling)

    expect(wargling.power).to eq(3)
    expect(wargling).to have_keyword(:trample)
    expect(giant).to have_keyword(:trample)
  end

  it "does nothing without a creature with power 4 or greater" do
    attack_with(wargling)

    expect(wargling.power).to eq(2)
    expect(wargling).not_to have_keyword(:trample)
  end
end
