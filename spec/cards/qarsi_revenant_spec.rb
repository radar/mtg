# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::QarsiRevenant do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Qarsi Revenant", owner: p1) }

  it "is a 3/3 Vampire with flying, deathtouch and lifelink" do
    permanent = ResolvePermanent("Qarsi Revenant", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([3, 3])
    expect([permanent.flying?, permanent.deathtouch?, permanent.lifelink?]).to eq([true, true, true])
  end

  it "renews for {2}{B}: a flying counter, a deathtouch counter and a lifelink counter on target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(black: 3)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { black: 2 }, black: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect([bear.flying?, bear.deathtouch?, bear.lifelink?]).to eq([true, true, true])
  end
end
