require 'spec_helper'

RSpec.describe Magic::Cards::StorySeeker do
  include_context "two player game"

  let!(:story_seeker) { ResolvePermanent("Story Seeker", owner: p2) }

  it "is a dwarf cleric" do
    expect(story_seeker.card.types).to include("Dwarf")
    expect(story_seeker.card.types).to include("Cleric")
    expect(story_seeker.card.types).to include("Creature")
  end

  it "has lifelink" do
    expect(story_seeker.lifelink?).to eq(true)
  end
end
