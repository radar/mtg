# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AvengerOfTheFallen do
  include_context "two player game"

  let!(:avenger) { ResolvePermanent("Avenger Of The Fallen", owner: p1) }

  def warriors = p1.creatures.select { _1.name == "Warrior" }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: avenger, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 2/4 with deathtouch" do
    expect([avenger.power, avenger.toughness]).to eq([2, 4])
    expect(avenger).to have_keyword(Magic::Cards::Keywords::DEATHTOUCH)
  end

  it "mobilizes X, where X is the number of creature cards in your graveyard" do
    2.times { p1.graveyard.add(Card("Grizzly Bears")) }
    attack
    expect(warriors.size).to eq(2)
  end

  it "creates nothing with no creature cards in the graveyard" do
    attack
    expect(warriors).to be_empty
  end
end
