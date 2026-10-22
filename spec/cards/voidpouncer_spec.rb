# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Voidpouncer do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:pouncer) { Card("Voidpouncer", owner: p1) }

  def cast_pouncer(kicked:)
    p1.hand.add(pouncer)
    p1.add_mana(red: 2, colorless: 3)
    action = cast_action(card: pouncer, player: p1)
    action.pay_mana(red: 1, generic: { red: 1 })
    action.pay_kicker(generic: { colorless: 2 }, colorless: 1) if kicked
    game.take_action(action)
    game.stack.resolve!
    game.settle!
    game.tick!
    p1.creatures.find { _1.name == "Voidpouncer" }
  end

  it "is a devoid 3/1 Eldrazi with {1}{R} cost" do
    permanent = ResolvePermanent("Voidpouncer", owner: p1)

    expect(pouncer.colors).to be_empty
    expect([permanent.power, permanent.toughness]).to eq([3, 1])
  end

  it "enters as a plain 3/1 without haste or counters when not kicked" do
    permanent = cast_pouncer(kicked: false)

    expect([permanent.power, permanent.toughness]).to eq([3, 1])
    expect(permanent.has_keyword?(:haste)).to be(false)
    expect(permanent.has_keyword?(:trample)).to be(false)
    expect(permanent.summoning_sick?).to be(true)
  end

  it "enters with two +1/+1 counters, a trample counter and haste when kicked" do
    permanent = cast_pouncer(kicked: true)

    expect([permanent.power, permanent.toughness]).to eq([5, 3])
    expect(permanent.counters.map(&:class).map(&:name)).to include("Magic::Counters::Trample")
    expect(permanent.has_keyword?(:trample)).to be(true)
    expect(permanent.has_keyword?(:haste)).to be(true)
    expect(permanent.summoning_sick?).to be(false)
  end
end
