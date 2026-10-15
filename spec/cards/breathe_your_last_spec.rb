# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BreatheYourLast do
  include_context "two player game"

  let(:card) { Card("Breathe Your Last", owner: p1) }

  def cast_on(target)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) do |a|
      a.pay_mana(generic: { black: 1 }, black: 2)
      a.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys a creature and gains 1 life for a mono-coloured one" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    expect { cast_on(bear) }.to change { p1.life }.by(1)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "gains 2 life for a two-coloured creature" do
    mentor = ResolvePermanent("Lilysplash Mentor", owner: p2)
    expect { cast_on(mentor) }.to change { p1.life }.by(2)
    expect(p2.graveyard.cards.map(&:name)).to include("Lilysplash Mentor")
  end

  it "gains no life for a colorless creature" do
    diver = ResolvePermanent("Junk Diver", owner: p2)
    expect { cast_on(diver) }.not_to change { p1.life }
    expect(p2.graveyard.cards.map(&:name)).to include("Junk Diver")
  end

  it "destroys a planeswalker and gains life for its colors" do
    garruk = ResolvePermanent("Garruk Unleashed", owner: p2)
    expect { cast_on(garruk) }.to change { p1.life }.by(1)
    expect(p2.graveyard.cards.map(&:name)).to include("Garruk, Unleashed")
  end

  it "cannot target a noncreature, nonplaneswalker permanent" do
    island = ResolvePermanent("Island", owner: p2)
    expect(card.target_choices).not_to include(island)
  end
end
