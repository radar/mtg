# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WarrenSoultrader do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:trader) { ResolvePermanent("Warren Soultrader", owner: p1) }
  let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def trade!(permanent)
    p1.activate_ability(ability: trader.activated_abilities.first) { _1.pay_sacrifice(permanent) }
    game.stack.resolve!
    game.settle!
  end

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  it "is a 3/3 Zombie Goblin Wizard" do
    expect([trader.power, trader.toughness]).to eq([3, 3])
  end

  it "creates a Treasure for 1 life and a sacrificed creature" do
    expect { trade!(fodder) }.to change { p1.life }.by(-1)

    expect(treasures.size).to eq(1)
    expect(p1.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
  end

  it "can't sacrifice itself" do
    expect { trade!(trader) }.to raise_error(StandardError)
  end

  it "can be activated again for each creature sacrificed" do
    second = ResolvePermanent("Grizzly Bears", owner: p1)
    trade!(fodder)
    trade!(second)

    expect(treasures.size).to eq(2)
    expect(p1.life).to eq(18)
  end
end
