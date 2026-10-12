# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfBurningAlive do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def fill_graveyard!
    %w[Grizzly\ Bears Forest Lightning\ Bolt World\ Map].each { p1.graveyard.add(Card(_1, owner: p1)) }
  end

  it "is a 4/4 Enchantment Creature — Nightmare" do
    fear = ResolvePermanent("Fear of Burning Alive", owner: p1)

    expect([fear.power, fear.toughness]).to eq([4, 4])
    expect(fear.type?("Enchantment")).to be(true)
  end

  it "deals 4 damage to each opponent when it enters" do
    expect { ResolvePermanent("Fear of Burning Alive", owner: p1) }.to change { p2.life }.by(-4)
  end

  it "without delirium deals no damage to a creature" do
    ResolvePermanent("Fear of Burning Alive", owner: p1)

    expect(bear.damage).to eq(0)
    expect(game.choices).to be_empty
  end

  it "with delirium deals that much damage to a creature that player controls" do
    fill_graveyard!
    expect(p1.graveyard.delirium?).to be(true)
    ResolvePermanent("Fear of Burning Alive", owner: p1)
    game.settle!

    expect(p2.life).to eq(16)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end
end
