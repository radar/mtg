# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FaebloomTrick do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Faebloom Trick", owner: p1) }

  def cast
    p1.hand.add(card)
    p1.add_mana(blue: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
  end

  def faeries = p1.creatures.select { _1.name == "Faerie" }

  it "creates two 1/1 blue Faerie tokens with flying" do
    cast

    expect(faeries.size).to eq(2)
    expect(faeries.map { [_1.power, _1.toughness] }.uniq).to eq([[1, 1]])
    expect(faeries).to all(be_flying)
    expect(faeries.first.colors).to eq([:blue])
  end

  it "is castable and still makes the tokens when the opponent has no creatures" do
    cast

    expect(faeries.size).to eq(2)
    expect(game.choices).to be_empty
  end

  it "taps the opponent's creature you choose when you do" do
    first = ResolvePermanent("Grizzly Bears", owner: p2)
    second = ResolvePermanent("Grizzly Bears", owner: p2)
    cast
    game.resolve_choice!(target: first)

    expect(first).to be_tapped
    expect(second).not_to be_tapped
    expect(faeries.size).to eq(2)
  end

  it "taps a lone opposing creature (a single target is chosen automatically)" do
    only = ResolvePermanent("Grizzly Bears", owner: p2)
    cast

    expect(only).to be_tapped
  end

  it "can't tap your own creature" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    cast

    expect(mine).not_to be_tapped
  end

  it "can be cast at instant speed on the opponent's turn" do
    game.next_turn
    cast

    expect(faeries.size).to eq(2)
  end
end
