# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MidnightMayhem do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:mayhem) { Card("Midnight Mayhem", owner: p1) }

  before do
    p1.hand.add(mayhem)
    p1.add_mana(red: 2, white: 2)
  end

  def gremlins = p1.creatures.select { _1.type?("Gremlin") }

  def cast!
    cast_and_resolve(card: mayhem, player: p1) { |a| a.pay_mana(generic: { red: 1, white: 1 }, red: 1, white: 1) }
    game.tick!
  end

  it "creates three 1/1 red Gremlin tokens" do
    cast!

    expect(gremlins.size).to eq(3)
    expect(gremlins.map { [_1.power, _1.toughness] }.uniq).to eq([[1, 1]])
    expect(gremlins.map(&:colors).uniq).to eq([[:red]])
  end

  it "gives Gremlins you control menace, lifelink and haste" do
    cast!

    expect(gremlins).to all(be_menace)
    expect(gremlins).to all(be_lifelink)
    expect(gremlins).to all(be_haste)
  end

  it "also affects Gremlins you already control" do
    existing = ResolvePermanent("Irreverent Gremlin", owner: p1)
    cast!

    expect(existing).to be_lifelink
  end

  it "does not affect other creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    cast!

    expect(bears).not_to be_lifelink
  end

  it "does not affect an opponent's Gremlins" do
    theirs = ResolvePermanent("Irreverent Gremlin", owner: p2)
    cast!

    expect(theirs).not_to be_lifelink
  end
end
