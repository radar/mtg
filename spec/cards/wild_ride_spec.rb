# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WildRide do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Wild Ride", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gives target creature +3/+0 and haste until end of turn" do
    p1.add_mana(red: 1)
    p1.cast(card: card) { |a| a.pay_mana(red: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect([bear.power, bear.toughness]).to eq([5, 2])
    expect(bear).to be_haste
    expect(card.zone).to be_graveyard
  end

  it "can be harmonized from the graveyard for {4}{R}, tapping a creature to reduce the cost by its power, then is exiled" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(red: 3)

    p1.cast(card: card, harmonize: true) do |a|
      a.harmonize_tap(other)
      a.pay_mana(generic: { red: 2 }, red: 1).targeting(bear)
    end
    game.stack.resolve!
    game.tick!

    expect(other).to be_tapped
    expect(bear.power).to eq(5)
    expect(card.zone).to be_exile
  end
end
