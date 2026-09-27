# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SunDappledCelebrant do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Sun-Dappled Celebrant", owner: p1) }

  before { p1.hand.add(card) }

  it "is a 5/6 treefolk cleric with vigilance" do
    celebrant = ResolvePermanent("Sun-Dappled Celebrant", owner: p1)

    expect(celebrant.card.types).to include("Treefolk", "Cleric")
    expect(celebrant.power).to eq(5)
    expect(celebrant.toughness).to eq(6)
    expect(celebrant).to have_keyword(:vigilance)
  end

  it "can be cast by tapping creatures to pay generic mana instead" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    other_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(white: 4)

    p1.cast(card: card) { |a| a.convoke(bears, pay: :generic).convoke(other_bears, pay: :generic).pay_mana(generic: { white: 2 }, white: 2) }
    game.stack.resolve!

    expect(bears).to be_tapped
    expect(other_bears).to be_tapped
    expect(card.zone).to be_battlefield
  end

  it "lets a creature pay one of its own colors toward a colored requirement" do
    story_seeker = ResolvePermanent("Story Seeker", owner: p1) # white
    p1.add_mana(white: 5)

    p1.cast(card: card) { |a| a.convoke(story_seeker, pay: :white).pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!

    expect(story_seeker).to be_tapped
    expect(card.zone).to be_battlefield
  end

  it "cannot tap an already-tapped creature to convoke" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!

    expect { p1.cast(card: card) { |a| a.convoke(bears) } }.to raise_error(/is tapped/)
  end

  it "cannot convoke with a creature you don't control" do
    opponents_bears = ResolvePermanent("Grizzly Bears", owner: p2)

    expect { p1.cast(card: card) { |a| a.convoke(opponents_bears) } }.to raise_error(/does not control/)
  end

  it "cannot convoke a color the creature doesn't have" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1) # green, not white

    expect { p1.cast(card: card) { |a| a.convoke(bears, pay: :white) } }.to raise_error(/is not white/)
  end

  it "cannot convoke past the generic cost remaining" do
    creatures = 5.times.map { ResolvePermanent("Grizzly Bears", owner: p1) }

    expect do
      p1.cast(card: card) { |a| creatures.each { |creature| a.convoke(creature, pay: :generic) } }
    end.to raise_error(/no generic mana left to convoke/)
  end
end
