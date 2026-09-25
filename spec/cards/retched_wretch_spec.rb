# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RetchedWretch do
  include_context "two player game"

  let!(:wretch) { ResolvePermanent("Retched Wretch", owner: p1) }

  def wretches = game.battlefield.creatures.by_name("Retched Wretch")

  it "is a 4/2 Goblin" do
    expect([wretch.power, wretch.toughness]).to eq([4, 2])
    expect(wretch).to be_type("Goblin")
  end

  it "stays dead if it had no -1/-1 counter" do
    wretch.destroy!
    expect(wretch.card.zone).to be_graveyard
    expect(wretches).to be_empty
  end

  context "when it dies with a -1/-1 counter on it" do
    before do
      wretch.add_counter("-1/-1")
      game.settle!
      wretch.destroy!
      game.settle!
    end

    it "returns to the battlefield under its owner's control" do
      expect(wretches.count).to eq(1)
      returned = wretches.first
      expect(returned).not_to eq(wretch)
      expect(returned.controller).to eq(p1)
      expect(returned.counters).to be_empty
      expect(wretch.card.zone).to be_battlefield
    end

    it "loses all abilities, so it doesn't return again" do
      returned = wretches.first
      expect(returned).to be_lost_all_abilities

      returned.add_counter("-1/-1")
      game.settle!
      returned.destroy!
      game.settle!
      expect(wretches).to be_empty
      expect(wretch.card.zone).to be_graveyard
    end
  end

  it "dies to -1/-1 counters and comes back" do
    wretch.add_counter("-1/-1", amount: 2)
    game.settle!

    expect(wretches.count).to eq(1)
    expect(wretches.first).to be_lost_all_abilities
  end
end
