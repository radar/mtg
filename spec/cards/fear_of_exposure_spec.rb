# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfExposure do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:fear) { Card("Fear of Exposure", owner: p1) }

  it "is a 5/4 trampling Enchantment Creature — Nightmare" do
    permanent = ResolvePermanent("Fear of Exposure", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([5, 4])
    expect(permanent.has_keyword?(:trample)).to be(true)
    expect(permanent.type?("Enchantment")).to be(true)
  end

  it "taps two untapped creatures and/or lands as an additional cost" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    forest = ResolvePermanent("Forest", owner: p1)
    p1.hand.add(fear)
    p1.add_mana(green: 3)
    p1.cast(card: fear) do |action|
      action.pay_mana(generic: { green: 2 }, green: 1)
      action.pay_additional_cost(Magic::Costs::MultiTap, [bears, forest])
    end
    game.stack.resolve!

    expect(bears.tapped?).to be(true)
    expect(forest.tapped?).to be(true)
    expect(p1.creatures.map(&:name)).to include("Fear of Exposure")
  end
end
