# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CuriosityCrafter do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:crafter) { ResolvePermanent("Curiosity Crafter", owner: p1) }

  def token = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!

  def deal_combat_damage(source, to:)
    game.notify!(Magic::Events::DamageDealt.new(source: source, target: to, damage: 1, combat: true))
    game.settle!
  end

  it "is a 3/3 flyer" do
    expect([crafter.power, crafter.toughness]).to eq([3, 3])
    expect(crafter).to be_flying
  end

  it "gives you no maximum hand size" do
    expect(p1.maximum_hand_size).to be_nil
  end

  it "draws a card when a creature token you control deals combat damage to a player" do
    expect { deal_combat_damage(token, to: p2) }.to change { p1.hand.count }.by(1)
  end

  it "does not draw for a nontoken creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { deal_combat_damage(bears, to: p2) }.not_to change { p1.hand.count }
  end

  it "does not draw for an opponent's token" do
    theirs = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p2).resolve!

    expect { deal_combat_damage(theirs, to: p1) }.not_to change { p1.hand.count }
  end
end
