# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CirithUngolPatrol do
  include_context "two player game"

  let!(:patrol) { ResolvePermanent("Cirith Ungol Patrol", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:ability) { patrol.activated_abilities.first }

  def foods = p1.permanents.select { _1.type?("Food") }

  def activate(fodder)
    p1.activate_ability(ability: ability) do |a|
      a.pay_mana(generic: { black: 1 })
      a.pay_sacrifice(fodder)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/5 Orc Soldier" do
    expect([patrol.power, patrol.toughness]).to eq([4, 5])
    expect(patrol.type?("Orc")).to be(true)
    expect(patrol.type?("Soldier")).to be(true)
  end

  it "sacrifices another creature to draw a card and create a Food token" do
    p1.add_mana(black: 1)
    hand_size = p1.hand.count

    activate(bears)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(p1.hand.count).to eq(hand_size + 1)
    expect(foods.count).to eq(1)
    expect(patrol).to be_tapped
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "can't sacrifice itself" do
    p1.add_mana(black: 1)

    expect { activate(patrol) }.to raise_error(StandardError)
    expect(foods).to be_empty
  end

  it "requires {1}" do
    expect { activate(bears) }.to raise_error(StandardError)
    expect(foods).to be_empty
  end

  it "can't be activated while tapped" do
    patrol.tap!
    p1.add_mana(black: 1)

    expect { activate(bears) }.to raise_error(StandardError)
    expect(foods).to be_empty
  end
end
