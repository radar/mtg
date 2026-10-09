# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WilderlandScrounger do
  include_context "two player game"

  let!(:scrounger) { ResolvePermanent("Wilderland Scrounger", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "puts a +1/+1 counter on each creature you control when you control a power 4 creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    giant = ResolvePermanent("Axegrinder Giant", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    attack_with(scrounger)

    expect(giant.power).to eq(7)
    expect(scrounger.power).to eq(4)
    expect(bears.power).to eq(3)
    expect(theirs.power).to eq(2)
  end

  it "does nothing without a creature with power 4 or greater" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(scrounger)

    expect(scrounger.power).to eq(3)
    expect(bears.power).to eq(2)
  end
end
