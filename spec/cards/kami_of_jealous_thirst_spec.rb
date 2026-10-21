# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KamiOfJealousThirst do
  include_context "two player game"

  let!(:kami) { ResolvePermanent("Kami Of Jealous Thirst", owner: p1) }

  def drain(mana: { black: 1, red: 4 }, payment: { generic: { red: 4 }, black: 1 })
    p1.add_mana(**mana) unless mana.empty?
    p1.activate_ability(ability: kami.activated_abilities.first) do |a|
      a.pay_mana(**payment) unless payment.empty?
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 1/3 deathtouch Spirit" do
    expect([kami.power, kami.toughness]).to eq([1, 3])
    expect(kami.keywords).to include(Magic::Cards::Keywords::DEATHTOUCH)
  end

  it "drains each opponent for 2 for {4}{B}" do
    expect { drain }.to change { p2.life }.by(-2)
    expect(p1.life).to eq(22)
  end

  it "can be activated only once each turn" do
    drain
    expect { drain }.to raise_error(Magic::IllegalAction, /can only be activated once each turn/)
    expect(p2.life).to eq(18)
  end

  it "can be activated again on the next turn" do
    drain
    current_turn.end!
    current_turn.cleanup!
    2.times { game.next_turn }
    expect { drain }.to change { p2.life }.by(-2)
  end

  it "cannot be activated when short of mana" do
    expect { drain(mana: { black: 1, red: 3 }, payment: {}) }.to raise_error(Magic::Costs::Mana::OutstandingBalance)
    expect(p2.life).to eq(20)
  end

  it "does not get cheaper when an opponent draws three cards" do
    3.times { p2.draw! }
    game.settle!
    expect { drain(mana: {}, payment: {}) }.to raise_error(Magic::Costs::Mana::OutstandingBalance)
    expect(p2.life).to eq(20)
  end

  it "costs {4}{B} less after drawing three cards this turn" do
    3.times { p1.draw! }
    game.settle!
    expect { drain(mana: {}, payment: {}) }.to change { p2.life }.by(-2)
  end

  it "still costs full price after drawing only two cards" do
    2.times { p1.draw! }
    game.settle!
    expect { drain(mana: {}, payment: {}) }.to raise_error(Magic::Costs::Mana::OutstandingBalance)
    expect(p2.life).to eq(20)
  end
end
