# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AlchemistsAssistant do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Alchemist's Assistant", owner: p1) }

  it "is a 2/1 Monkey with lifelink" do
    permanent = ResolvePermanent("Alchemist's Assistant", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 1])
    expect(permanent).to be_lifelink
  end

  it "renews for {1}{B}: a lifelink counter on target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(black: 2)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect(bear).to be_lifelink
  end
end
