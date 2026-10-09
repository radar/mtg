# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BolgsCompany do
  include_context "two player game"

  let!(:company) { ResolvePermanent("Bolg's Company", owner: p1) }

  it "is a 2/2 Goblin Soldier" do
    expect([company.power, company.toughness]).to eq([2, 2])
    expect(company.card.types).to include("Goblin", "Soldier")
  end

  it "has haste only while you control another Goblin" do
    game.tick!
    expect(company.haste?).to be(false)

    other = ResolvePermanent("Bothersome Noisemaker", owner: p1)
    game.tick!
    expect(company.haste?).to be(true)

    other.destroy!
    game.settle!
    game.tick!
    expect(company.haste?).to be(false)
  end

  it "doesn't count an opponent's Goblin for haste" do
    ResolvePermanent("Bothersome Noisemaker", owner: p2)
    game.tick!

    expect(company.haste?).to be(false)
  end

  it "taps and sacrifices another Goblin for {B}{R}" do
    goblin = ResolvePermanent("Bothersome Noisemaker", owner: p1)
    p1.activate_ability(ability: company.activated_abilities.first) { |a| a.pay_sacrifice(goblin) }
    game.settle!

    expect(p1.mana_pool[:black]).to eq(1)
    expect(p1.mana_pool[:red]).to eq(1)
    expect(company).to be_tapped
    expect(p1.graveyard.cards.map(&:name)).to include("Bothersome Noisemaker")
  end

  it "can't sacrifice itself" do
    expect {
      p1.activate_ability(ability: company.activated_abilities.first) { |a| a.pay_sacrifice(company) }
    }.to raise_error(StandardError)
  end
end
