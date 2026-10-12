# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FinishingBlow do
  include_context "two player game"

  def cast(target)
    card = Card("Finishing Blow", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 5)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 4 }, black: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "destroys target creature" do
    angel = ResolvePermanent("Serra Angel", owner: p2)
    cast(angel)

    expect(angel.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "destroys target planeswalker" do
    walker = ResolvePermanent("Ob Nixilis Reignited", owner: p2)
    cast(walker)

    expect(walker.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "can be cast at instant speed" do
    angel = ResolvePermanent("Serra Angel", owner: p2)

    expect { cast(angel) }.not_to raise_error
  end
end
