# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Hobblefiend do
  include_context "two player game"

  let!(:hobblefiend) { ResolvePermanent("Hobblefiend", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/1 Devil with trample" do
    expect([hobblefiend.power, hobblefiend.toughness]).to eq([2, 1])
    expect(hobblefiend.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
  end

  it "gets a +1/+1 counter when you sacrifice another creature" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability: hobblefiend.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 1 })
      a.pay_sacrifice(bears)
    end
    game.stack.resolve!
    game.settle!

    expect([hobblefiend.power, hobblefiend.toughness]).to eq([3, 2])
    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "can't sacrifice itself" do
    p1.add_mana(red: 1)

    expect do
      p1.activate_ability(ability: hobblefiend.activated_abilities.first) do |a|
        a.pay_mana(generic: { red: 1 })
        a.pay_sacrifice(hobblefiend)
      end
    end.to raise_error(StandardError)
  end
end
