require 'spec_helper'

RSpec.describe Magic::Cards::JungleHollow do
  include_context "two player game"

  let(:card) { described_class.new(game: game) }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Jungle Hollow").first
  end

  it "enters the battlefield tapped" do
    game.stack.resolve!
    expect(permanent).to be_tapped
  end

  it "has the controller gain life" do
    expect(p1.life).to eq(21)
  end

  it "taps for either black or green" do
    p1.activate_ability(ability: permanent.activated_abilities.first)
    game.resolve_pending_effect(black: 1)
    expect(game.effects).to be_empty
    expect(p1.mana_pool[:black]).to eq(1)
  end
end