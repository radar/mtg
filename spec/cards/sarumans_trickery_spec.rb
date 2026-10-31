# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SarumansTrickery do
  include_context "two player game"
  before { go_to_main_phase_for!(p2) }

  let(:sol_ring) { Card("Sol Ring") }
  let(:trickery) { Card("Saruman's Trickery", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

  def cast_trickery(target_action)
    p1.hand.add(trickery)
    p1.add_mana(blue: 3)
    p1.cast(card: trickery) do
      _1.pay_mana(generic: { blue: 1 }, blue: 2)
      _1.targeting(target_action)
    end
  end

  before do
    p2.hand.add(sol_ring)
    p2.add_mana(red: 1)
  end

  let!(:sol_ring_cast) { p2.cast(card: sol_ring) { _1.pay_mana(generic: { red: 1 }) } }

  it "counters target spell" do
    cast_trickery(sol_ring_cast)
    game.stack.resolve!
    game.tick!
    expect(sol_ring.zone).to be_graveyard
    expect(trickery.zone).to be_graveyard
    expect(game.battlefield.permanents.map(&:name)).not_to include("Sol Ring")
  end

  it "amasses Orcs 1 for its controller" do
    cast_trickery(sol_ring_cast)
    game.stack.resolve!
    game.tick!
    expect(army.type?("Orc")).to eq(true)
    expect([army.power, army.toughness]).to eq([1, 1])
    expect(p2.creatures.any? { _1.type?("Army") }).to eq(false)
  end

  it "does not counter the spell or amass until it resolves" do
    cast_trickery(sol_ring_cast)
    expect(sol_ring.zone).not_to be_graveyard
    expect(army).to be_nil
  end

  it "adds to an existing Army" do
    Magic::Amass.call(source: trickery, controller: p1, amount: 1, subtype: "Orc")
    game.tick!
    cast_trickery(sol_ring_cast)
    game.stack.resolve!
    game.tick!
    expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
    expect(army.power).to eq(2)
  end
end
