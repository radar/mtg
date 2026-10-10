# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfIsolation do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:fear) { Card("Fear of Isolation", owner: p1) }

  it "is a 2/3 flying Enchantment Creature — Nightmare" do
    permanent = ResolvePermanent("Fear of Isolation", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 3])
    expect(permanent.has_keyword?(:flying)).to be(true)
    expect(permanent.type?("Enchantment")).to be(true)
    expect(permanent.type?("Nightmare")).to be(true)
  end

  it "returns a permanent you control to hand as an additional cost" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(fear)
    p1.add_mana(blue: 2)
    p1.cast(card: fear) do |action|
      action.pay_mana(generic: { blue: 1 }, blue: 1)
      action.pay_additional_cost(Magic::Costs::ReturnPermanent, bears)
    end
    game.stack.resolve!

    expect(p1.hand.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.creatures.map(&:name)).to eq(["Fear of Isolation"])
  end
end
