# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShelobsAmbush do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Shelob's Ambush", owner: p1) }
  let!(:target) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def cast(creature)
    p1.hand.add(spell)
    p1.add_mana(black: 1)
    p1.cast(card: spell) { |a| a.pay_mana(black: 1).targeting(creature) }
    game.stack.resolve!
    game.settle!
  end

  it "gives the target +1/+2 and deathtouch" do
    cast(target)

    expect(target.power).to eq(3)
    expect(target.toughness).to eq(4)
    expect(target.deathtouch?).to be(true)
  end

  it "does not affect other creatures" do
    cast(target)

    expect(other.power).to eq(2)
    expect(other.toughness).to eq(2)
    expect(other.deathtouch?).to be(false)
  end

  it "wears off at end of turn" do
    cast(target)
    current_turn.end!
    current_turn.cleanup!
    game.settle!

    expect(target.power).to eq(2)
    expect(target.toughness).to eq(2)
    expect(target.deathtouch?).to be(false)
  end

  it "creates a Food token" do
    cast(target)

    expect(foods.count).to eq(1)
    expect(p2.permanents.select { _1.type?("Food") }).to be_empty
  end
end
