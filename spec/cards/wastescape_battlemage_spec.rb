# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WastescapeBattlemage do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:mage) { Card("Wastescape Battlemage", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:opp_bear2) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:opp_sol_ring) { ResolvePermanent("Sol Ring", owner: p2) }
  let!(:opp_plate) { ResolvePermanent("Abundance", owner: p2) }

  def cast_mage(green: false, blue: false)
    p1.hand.add(mage)
    p1.add_mana(colorless: 2, green: 1, blue: 1, red: 1)
    action = cast_action(card: mage, player: p1)
    action.pay_mana(colorless: 1, generic: { red: 1 })
    action.pay_kicker(green: 1) if green
    action.pay_kicker(generic: { red: 1 }, blue: 1) if blue
    game.take_action(action)
    game.settle!
  end

  def exiled_names = game.exile.cards.map(&:name)

  def p2_hand_names = p2.hand.cards.map(&:name).reject { _1 == "Mountain" }

  it "is a 2/2 Eldrazi Wizard" do
    permanent = ResolvePermanent("Wastescape Battlemage", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 2])
  end

  it "does nothing extra when not kicked" do
    cast_mage

    expect(game.choices).to be_empty
    expect(exiled_names).to be_empty
    expect(opp_bears.zone).to eq(game.battlefield)
  end

  it "exiles an opponent's artifact or enchantment when kicked with {G}" do
    cast_mage(green: true)
    choice = game.choices.last

    expect(choice).to be_a(described_class::ExileChoice)
    expect(choice.choices).to contain_exactly(opp_sol_ring, opp_plate)
    game.resolve_choice!(target: opp_sol_ring)

    expect(exiled_names).to eq(["Sol Ring"])
    expect(p2_hand_names).to be_empty
  end

  it "returns an opponent's creature to hand when kicked with {1}{U}" do
    cast_mage(blue: true)
    choice = game.choices.last

    expect(choice).to be_a(described_class::BounceChoice)
    expect(choice.choices).to contain_exactly(opp_bears, opp_bear2)
    game.resolve_choice!(target: opp_bears)

    expect(p2_hand_names).to eq(["Grizzly Bears"])
    expect(exiled_names).to be_empty
  end

  it "does both when kicked with both kickers" do
    cast_mage(green: true, blue: true)
    first = game.choices.first
    game.resolve_choice!(target: first.choices.first)
    game.settle!
    second = game.choices.first
    game.resolve_choice!(target: second.choices.first)

    expect([first.class, second.class]).to contain_exactly(described_class::ExileChoice, described_class::BounceChoice)
    expect(exiled_names.size).to eq(1)
    expect(p2_hand_names).to eq(["Grizzly Bears"])
  end

  it "forgets the kickers once the spell has resolved" do
    cast_mage(green: true)
    game.skip_choice!
    game.stack.resolve!

    expect(mage.kicker_cost.paid?).to be(false)
  end
end
