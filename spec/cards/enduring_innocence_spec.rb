# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnduringInnocence do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:innocence) { ResolvePermanent("Enduring Innocence", owner: p1) }

  it "is a 2/1 Enchantment Creature — Sheep Glimmer with lifelink" do
    expect([innocence.power, innocence.toughness]).to eq([2, 1])
    expect(innocence.type?("Enchantment")).to be(true)
    expect(innocence.lifelink?).to be(true)
  end

  it "draws a card when another creature with power 2 or less enters under your control" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.to change { p1.hand.count }.by(1)
  end

  it "does not draw for a creature with power 3 or more" do
    expect { ResolvePermanent("Serra Angel", owner: p1) }.not_to(change { p1.hand.count })
  end

  it "does not draw for an opponent's creature" do
    expect { ResolvePermanent("Grizzly Bears", owner: p2) }.not_to(change { p1.hand.count })
  end

  it "triggers only once each turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.not_to(change { p1.hand.count })
  end

  it "returns as a non-creature enchantment when it dies" do
    innocence.destroy!
    game.settle!

    returned = game.battlefield.cards.by_name("Enduring Innocence").first
    expect(returned.creature?).to be(false)
    expect(returned.type?("Enchantment")).to be(true)
  end
end
