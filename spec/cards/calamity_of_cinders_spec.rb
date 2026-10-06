# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CalamityOfCinders do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_with_mana
    card = Card("Calamity Of Cinders", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 7)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 5 }, red: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "deals 6 damage to each untapped creature" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p2) # 5/5
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    cast_with_mana

    expect(angel.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "spares tapped creatures" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p2)
    angel.tap!

    cast_with_mana

    expect(angel.zone).to be_a(Magic::Zones::Battlefield)
  end

  it "has convoke: tapped creatures help pay and are spared" do
    elves = 2.times.map { ResolvePermanent("Llanowar Elves", owner: p1) }
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Calamity Of Cinders", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 5)

    p1.cast(card:) do |a|
      a.convoke(elves[0])
      a.convoke(elves[1])
      a.pay_mana(generic: { red: 3 }, red: 2)
    end
    game.stack.resolve!
    game.settle!

    expect(elves.map { _1.zone.class }).to all(eq(Magic::Zones::Battlefield))
    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end
end
