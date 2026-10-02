# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeraldOfFaith do
  include_context "two player game"

  let!(:herald) { ResolvePermanent("Herald Of Faith", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 4/3 flying Angel" do
    expect([herald.power, herald.toughness]).to eq([4, 3])
    expect(herald).to be_flying
  end

  it "gains you 2 life when it attacks" do
    attack_with(herald)

    expect(p1.life).to eq(22)
  end

  it "doesn't trigger when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(p1.life).to eq(20)
  end
end
