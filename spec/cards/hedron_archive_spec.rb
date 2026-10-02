# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HedronArchive do
  include_context "two player game"

  let!(:archive) { ResolvePermanent("Hedron Archive", owner: p1) }

  it "taps for {C}{C}" do
    p1.activate_ability(ability: archive.activated_abilities.first)

    expect(archive).to be_tapped
    expect(p1.mana_pool[:colorless]).to eq(2)
  end

  it "sacrifices itself for {2} to draw two cards" do
    hand_size = p1.hand.count
    p1.add_mana(green: 2)
    p1.activate_ability(ability: archive.activated_abilities.last) { _1.pay_mana(generic: { green: 2 }) }
    game.stack.resolve!

    expect(archive.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand_size + 2)
  end
end
