require 'spec_helper'

RSpec.describe Magic::Cards::GolgariGuildgate do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:card) { described_class.new(game: game, controller: p1) }

  it "enters the battlefield tapped" do
    card.cast!
    game.stack.resolve!
    expect(card).to be_tapped
  end

  it "taps for either black or green" do
    card.cast!
    card.untap!
    card.tap!
    add_mana_ability = game.effects.first
    expect(add_mana_ability).to be_a(Magic::Effects::AddManaOrAbility)
    game.resolve_effect(add_mana_ability, black: 1)
    expect(game.effects).to be_empty
    expect(p1.mana_pool[:black]).to eq(1)
  end
end
