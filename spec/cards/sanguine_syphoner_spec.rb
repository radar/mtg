# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanguineSyphoner do
  include_context "two player game"

  let!(:syphoner) { ResolvePermanent("Sanguine Syphoner", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 1/3 Vampire Warlock" do
    expect([syphoner.power, syphoner.toughness]).to eq([1, 3])
  end

  it "makes each opponent lose 1 life and gains you 1 life when it attacks" do
    attack_with(syphoner)

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end

  it "doesn't trigger when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
  end
end
