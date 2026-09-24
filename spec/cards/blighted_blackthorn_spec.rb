require "spec_helper"

RSpec.describe Magic::Cards::BlightedBlackthorn do
  include_context "two player game"

  let!(:blackthorn) { ResolvePermanent("Blighted Blackthorn", owner: p1) }

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a 3/7" do
    game.skip_choice!
    expect([blackthorn.power, blackthorn.toughness]).to eq([3, 7])
  end

  it "may blight 2 when it enters; if you do, you draw a card and lose 1 life" do
    game.resolve_choice!
    game.resolve_choice!(target: blackthorn)

    expect(minus_counters(blackthorn)).to eq(2)
    expect(p1.hand.count).to eq(8)
    expect(p1.life).to eq(19)
  end

  it "does nothing when you decline on entering" do
    game.skip_choice!

    expect(p1.hand.count).to eq(7)
    expect(p1.life).to eq(20)
  end

  it "may blight 2 again whenever it attacks" do
    game.skip_choice!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: blackthorn, target: p2)
    current_turn.attackers_declared!

    game.resolve_choice!
    game.resolve_choice!(target: blackthorn)

    expect(minus_counters(blackthorn)).to eq(2)
    expect(p1.life).to eq(19)
  end
end
