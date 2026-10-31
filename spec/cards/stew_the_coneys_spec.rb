# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StewTheConeys do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Stew The Coneys", owner: p1) }
  let!(:angel) { ResolvePermanent("Serra Angel", owner: p1) } # 4/4
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) } # 2/2
  let!(:theirs) { ResolvePermanent("Baneslayer Angel", owner: p2) } # 5/5
  let!(:their_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def pay_and_target(*targets)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(*targets) }
  end

  def cast(*targets)
    p1.hand.add(spell)
    p1.add_mana(green: 3)
    pay_and_target(*targets)
    game.stack.resolve!
    game.settle!
  end

  it "has your creature deal damage equal to its power to the other creature" do
    cast(angel, their_bears)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(theirs.damage).to eq(0)
  end

  it "deals damage equal to the power, not more" do
    cast(bears, theirs)

    expect(theirs.damage).to eq(2)
    expect(theirs.zone).to be_a(Magic::Zones::Battlefield)
  end

  it "is one-sided: the targeted opposing creature deals no damage back" do
    cast(bears, theirs)

    expect(bears.damage).to eq(0)
  end

  it "creates a Food token" do
    cast(bears, theirs)

    expect(foods.count).to eq(1)
  end

  it "cannot use a creature you don't control as the damage source" do
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    expect { pay_and_target(theirs, their_bears) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "cannot damage a creature you control" do
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    expect { pay_and_target(angel, bears) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
