# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WanderbrineTrapper do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:trapper) { ResolvePermanent("Wanderbrine Trapper", owner: p1) }
  let!(:helper) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:victim) { ResolvePermanent("Courser Of Kruphix", owner: p2) }

  def activate(tapping: helper, target: victim)
    p1.add_mana(white: 1)
    p1.activate_ability(ability: trapper.activated_abilities.first) do |action|
      action.pay_mana(generic: { white: 1 }).pay_multi_tap([tapping]).targeting(target)
    end
    game.stack.resolve!
  end

  it "is a 2/1 Merfolk Scout" do
    expect([trapper.power, trapper.toughness]).to eq([2, 1])
  end

  it "taps itself, another untapped creature you control and {1} to tap target opposing creature" do
    activate

    expect(victim).to be_tapped
    expect(trapper).to be_tapped
    expect(helper).to be_tapped
  end

  it "can only target creatures an opponent controls" do
    expect(trapper.activated_abilities.first.target_choices).to contain_exactly(victim)
  end

  it "can't tap itself as the other creature" do
    expect { activate(tapping: trapper) }.to raise_error(/Tap exactly 1/)
  end

  it "can't tap an already tapped creature as the other creature" do
    helper.tap!

    expect { activate }.to raise_error(/Tap exactly 1/)
  end
end
