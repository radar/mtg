require 'spec_helper'

RSpec.describe Magic::Cards::GolgariGuildgate do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:card) { described_class.new(game: game, controller: p1) }

  it "enters the battlefield tapped" do
    card.draw!
    card.cast!
    game.stack.resolve!
    expect(card).to be_tapped
  end

  it "taps for either black or green" do
    card.draw!
    card.cast!
    card.untap!
    card.tap!
    expect(game.effects.count).to eq(1)
    game.resolve_effect(Magic::Effects::AddManaOrAbility, black: 1)
    expect(game.effects).to be_empty
    expect(p1.mana_pool[:black]).to eq(1)
  end
end
