# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Graveshifter do
  include_context "two player game"

  it "is a 2/2 shapeshifter with changeling" do
    shifter = ResolvePermanent("Graveshifter", owner: p1)

    expect(shifter.power).to eq(2)
    expect(shifter.toughness).to eq(2)
    expect(shifter.card.changeling?).to be(true)
  end

  it "may return target creature card from your graveyard to your hand when it enters" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bears)
    ResolvePermanent("Graveshifter", owner: p1)

    game.resolve_choice! # accept the "may"; bears is the only legal target, so it auto-resolves

    expect(bears.zone).to be_hand
  end

  it "lets you choose which creature card, with more than one in the graveyard" do
    bears = Card("Grizzly Bears", owner: p1)
    story_seeker = Card("Story Seeker", owner: p1)
    p1.graveyard.add(bears)
    p1.graveyard.add(story_seeker)
    ResolvePermanent("Graveshifter", owner: p1)

    game.resolve_choice!
    game.resolve_choice!(target: story_seeker)

    expect(story_seeker.zone).to be_hand
    expect(bears.zone).to be_graveyard
  end

  it "does not offer the choice with no creature card in the graveyard" do
    ResolvePermanent("Graveshifter", owner: p1)

    expect(game.choices).to be_empty
  end
end
