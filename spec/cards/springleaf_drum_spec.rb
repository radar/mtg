# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpringleafDrum do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:drum) { ResolvePermanent("Springleaf Drum", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "taps itself and an untapped creature you control for one mana of any color" do
    ability = drum.activated_abilities.first
    p1.activate_ability(ability:) { |a| a.pay_multi_tap([bears]).choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
    expect(drum).to be_tapped
    expect(bears).to be_tapped
  end

  it "needs an untapped creature" do
    bears.tap!

    expect(drum.activated_abilities.first.costs.last.can_pay?(p1)).to be(false)
  end

  it "can't tap an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    ability = drum.activated_abilities.first

    expect { p1.activate_ability(ability:) { |a| a.pay_multi_tap([theirs]).choose(:red) } }.to raise_error(/Tap exactly 1/)
  end
end
