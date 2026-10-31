# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SecondBreakfast do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Second Breakfast", owner: p1) }
  let!(:first) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:second) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:third) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def cast(*targets)
    p1.hand.add(spell)
    p1.add_mana(white: 3)
    p1.cast(card: spell) do |a|
      a.pay_mana(generic: { white: 2 }, white: 1)
      a.targeting(*targets) if targets.any?
    end
    game.stack.resolve!
    game.settle!
  end

  it "gives each of two target creatures +2/+1 until end of turn" do
    cast(first, second)

    expect(first.power).to eq(4)
    expect(first.toughness).to eq(3)
    expect(second.power).to eq(4)
    expect(second.toughness).to eq(3)
    expect(third.power).to eq(2)
    expect(third.toughness).to eq(2)
  end

  it "wears off at end of turn" do
    cast(first, second)
    current_turn.end!
    current_turn.cleanup!
    game.settle!

    expect(first.power).to eq(2)
    expect(first.toughness).to eq(2)
  end

  it "can target just one creature" do
    cast(first)

    expect(first.power).to eq(4)
    expect(second.power).to eq(2)
  end

  it "can be cast with no targets and still creates a Food" do
    cast

    expect(first.power).to eq(2)
    expect(foods.count).to eq(1)
  end

  it "rejects a third target" do
    p1.hand.add(spell)
    p1.add_mana(white: 3)

    expect do
      p1.cast(card: spell) do |a|
        a.pay_mana(generic: { white: 2 }, white: 1)
        a.targeting(first, second, third)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "creates a Food token" do
    cast(first, second)

    expect(foods.count).to eq(1)
    expect(p2.permanents.select { _1.type?("Food") }).to be_empty
  end
end
