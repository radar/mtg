# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WanderwineFarewell do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:farewell) { Card("Wanderwine Farewell") }

  def cast_farewell(*targets)
    p1.hand.add(farewell)
    p1.add_mana(blue: 7)
    p1.cast(card: farewell) do |action|
      action.pay_mana(blue: 2, generic: { blue: 5 })
      action.targeting(*targets)
    end
    game.stack.resolve!
    game.tick!
  end

  it "has convoke" do
    expect(farewell.convoke?).to eq(true)
  end

  it "can be cast by tapping creatures" do
    creatures = 5.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }
    p1.hand.add(farewell)
    p1.add_mana(blue: 2)
    p1.cast(card: farewell) do |action|
      creatures.each { |creature| action.convoke(creature) }
      action.pay_mana(blue: 2)
      action.targeting(ResolvePermanent("Grizzly Bears", owner: p2))
    end
    expect(creatures).to all(be_tapped)
  end

  it "returns two nonland permanents and makes a Merfolk token for each if you control a Merfolk" do
    merfolk = ResolvePermanent("Tributary Vaulter", owner: p1)
    ResolvePermanent("Tributary Vaulter", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_farewell(merfolk, bears)

    expect(p1.hand.cards).to include(merfolk.card)
    expect(p2.hand.cards).to include(bears.card)
    tokens = p1.creatures.select(&:token?)
    expect(tokens.count).to eq(2)
    expect(tokens.first.name).to eq("Merfolk")
    expect(tokens.first.colors).to contain_exactly(:white, :blue)
  end

  it "makes no tokens without a Merfolk" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_farewell(bears)

    expect(p2.hand.cards).to include(bears.card)
    expect(p1.creatures).to be_empty
  end

  it "makes no tokens if the only Merfolk you controlled was returned" do
    merfolk = ResolvePermanent("Tributary Vaulter", owner: p1)
    cast_farewell(merfolk)

    expect(p1.creatures).to be_empty
  end
end
