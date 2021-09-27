require 'spec_helper'

RSpec.describe Magic::Cards::GolgariGuildgate do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:card) { described_class.new(controller: p1) }

  it "enters the battlefield tapped" do
    card.draw!
    card.cast!
    expect(card).to be_tapped
  end

  it "taps for either black or green" do
    card.draw!
    card.cast!
    card.untap!
    card.tap!
    expect(mana_ability).to be_a(Magic::Effects::AddManaOrAbility)
    expect(mana_ability.black).to eq(1)
    expect(mana_ability.green).to eq(1)
    mana_ability.choose
  end
end
