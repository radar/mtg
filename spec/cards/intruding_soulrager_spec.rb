# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IntrudingSoulrager do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:soulrager) { ResolvePermanent("Intruding Soulrager", owner: p1) }
  let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:right]) }

  it "is a 2/2 Spirit with vigilance" do
    expect([soulrager.power, soulrager.toughness]).to eq([2, 2])
    expect(soulrager).to have_keyword(:vigilance)
  end

  it "taps and sacrifices a Room to deal 2 damage to each opponent and draw a card" do
    hand_size = p1.hand.cards.count
    p1.activate_ability(ability: soulrager.activated_abilities.first) { |a| a.pay_sacrifice(room) }
    game.stack.resolve!
    game.settle!

    expect(room.zone).to be_nil
    expect(soulrager).to be_tapped
    expect(p2.life).to eq(18)
    expect(p1.life).to eq(20)
    expect(p1.hand.cards.count).to eq(hand_size + 1)
  end

  it "offers only Rooms you control as the sacrifice" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Funeral Room Awakening Hall", owner: p2, doors: [:left])
    ability = soulrager.activated_abilities.first
    sacrifice = ability.costs.find { _1.is_a?(Magic::Costs::Sacrifice) }

    expect(sacrifice.choices).to eq([room])
  end
end
