# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DreadSummons do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Dread Summons", owner: p1) }

  def stock_library(player, *names)
    player.library.items.clear
    names.reverse_each { player.library.add(Card(_1, owner: player)) }
  end

  def cast(x:)
    p1.hand.add(card)
    p1.add_mana(black: x + 2)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { black: x }, black: 2) }
    game.stack.resolve!
    game.settle!
  end

  def zombies(player = p1) = player.creatures.select { _1.name == "Zombie" }

  it "makes a tapped 2/2 black Zombie for each creature card milled from either library" do
    stock_library(p1, "Grizzly Bears", "Island", "Grizzly Bears", "Island")
    stock_library(p2, "Grizzly Bears", "Grizzly Bears", "Island")
    cast(x: 3)

    expect(p1.graveyard.count).to eq(4) # 3 milled + the spell
    expect(p2.library.count).to eq(0)
    expect(zombies.size).to eq(4)
    expect(zombies).to all(be_tapped)
    expect(zombies.map { [_1.power, _1.toughness] }.uniq).to eq([[2, 2]])
    expect(zombies.first.colors).to eq([:black])
  end

  it "gives the Zombies only to you, even for the opponent's milled creatures" do
    stock_library(p1, "Island", "Island")
    stock_library(p2, "Grizzly Bears", "Grizzly Bears")
    cast(x: 2)

    expect(zombies.size).to eq(2)
    expect(zombies(p2)).to be_empty
  end

  it "makes no Zombies when no creature cards are milled" do
    stock_library(p1, "Island", "Island")
    stock_library(p2, "Island", "Island")
    cast(x: 2)

    expect(zombies).to be_empty
    expect(p2.graveyard.count).to eq(2)
  end

  it "mills nothing and makes no Zombies for X = 0" do
    cast(x: 0)

    expect(zombies).to be_empty
    expect(p1.graveyard.count).to eq(1)
  end

  it "mills only what a short library has" do
    stock_library(p1, "Grizzly Bears")
    stock_library(p2, "Island")
    cast(x: 5)

    expect(p1.library.count).to eq(0)
    expect(zombies.size).to eq(1)
  end
end
