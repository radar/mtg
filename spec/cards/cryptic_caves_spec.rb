# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CrypticCaves do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:caves) { ResolvePermanent("Cryptic Caves", owner: p1) }

  def lands(count) = count.times.map { ResolvePermanent("Forest", owner: p1) }

  def sacrifice_for_card
    p1.add_mana(colorless: 1)
    p1.activate_ability(ability: caves.activated_abilities.last) { |a| a.pay_mana(generic: { colorless: 1 }) }
    game.stack.resolve!
  end

  it "taps for {C}" do
    p1.activate_ability(ability: caves.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "draws a card for {1}, {T} and sacrificing it when you control five or more lands" do
    lands(4) # with Cryptic Caves itself, five lands
    hand = p1.hand.count
    sacrifice_for_card

    expect(caves.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "can't be activated with fewer than five lands" do
    lands(3)
    hand = p1.hand.count

    expect { sacrifice_for_card }.to raise_error(Magic::IllegalAction)
    expect(caves.zone).to be_battlefield
    expect(caves).not_to be_tapped
    expect(p1.hand.count).to eq(hand)
  end

  it "doesn't count your opponent's lands" do
    lands(2)
    2.times { ResolvePermanent("Mountain", owner: p2) }

    expect { sacrifice_for_card }.to raise_error(Magic::IllegalAction)
  end

  it "counts the land being sacrificed itself, since the restriction is checked before costs are paid" do
    lands(4)

    expect { sacrifice_for_card }.not_to raise_error
  end
end
