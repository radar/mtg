# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ManaGeyser do
  include_context "two player game"
  before { go_to_main_phase! }

  subject(:mana_geyser) { Card("Mana Geyser", owner: p1) }

  before do
    p1.hand.add(mana_geyser)
  end

  it "adds {R} for each tapped land your opponents control" do
    tapped_mountain = ResolvePermanent("Mountain", owner: p2)
    tapped_island = ResolvePermanent("Island", owner: p2)
    untapped_forest = ResolvePermanent("Forest", owner: p2)
    tapped_mountain.tap!
    tapped_island.tap!

    expect(untapped_forest.tapped?).to eq(false)

    p1.add_mana(red: 5)
    p1.cast(card: mana_geyser) do |action|
      action.pay_mana(generic: { red: 3 }, red: 2)
    end
    game.stack.resolve!

    expect(p1.mana_pool[:red]).to eq(2)
  end

  it "doesn't count lands the caster controls" do
    ResolvePermanent("Mountain", owner: p1).tap!

    p1.add_mana(red: 5)
    p1.cast(card: mana_geyser) do |action|
      action.pay_mana(generic: { red: 3 }, red: 2)
    end
    game.stack.resolve!

    expect(p1.mana_pool[:red]).to eq(0)
  end

  it "doesn't count opponents' untapped lands" do
    ResolvePermanent("Mountain", owner: p2)

    p1.add_mana(red: 5)
    p1.cast(card: mana_geyser) do |action|
      action.pay_mana(generic: { red: 3 }, red: 2)
    end
    game.stack.resolve!

    expect(p1.mana_pool[:red]).to eq(0)
  end
end
