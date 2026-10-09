# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WoodlandWeavemaster do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:weavemaster) { ResolvePermanent("Woodland Weavemaster", owner: p1) }

  it "has vigilance" do
    expect(weavemaster).to have_keyword(:vigilance)
  end

  it "gets +1/+1 until end of turn whenever another Elf you control enters" do
    ResolvePermanent("Llanowar Elves", owner: p1)
    game.settle!
    game.tick!

    expect([weavemaster.power, weavemaster.toughness]).to eq([2, 3])
  end

  it "ignores non-Elves and opponents' Elves" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p2)
    game.settle!
    game.tick!

    expect(weavemaster.power).to eq(1)
  end

  def tap_for(color)
    p1.activate_ability(ability: weavemaster.activated_abilities.first) { |a| a.choose(color) }
  end

  it "taps for X restricted mana of one color, X being its power" do
    tap_for(:green)

    expect(p1.restricted_mana.map(&:color)).to eq([:green])
  end

  it "adds more mana as its power grows" do
    ResolvePermanent("Llanowar Elves", owner: p1)
    game.settle!
    game.tick!
    tap_for(:blue)

    expect(p1.restricted_mana.map(&:color)).to eq(%i[blue blue])
  end

  it "can't be spent on a non-Elf spell" do
    tap_for(:green)
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    action = Magic::Actions::Cast.new(card: bears, player: p1, game: game)

    expect(action.mana_cost.can_pay?(p1)).to eq(false)
  end

  it "can be spent on an Elf spell" do
    tap_for(:green)
    p1.add_mana(green: 0)
    elves = Card("Llanowar Elves", owner: p1)
    p1.hand.add(elves)
    action = Magic::Actions::Cast.new(card: elves, player: p1, game: game)

    expect(action.mana_cost.can_pay?(p1)).to eq(true)
  end
end
