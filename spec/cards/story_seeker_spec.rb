require 'spec_helper'

RSpec.describe Magic::Cards::StorySeeker do
  include_context "two player game"

  let!(:story_seeker) { ResolvePermanent("Story Seeker", owner: p2) }

  it "is a dwarf cleric" do
    expect(story_seeker.card.type_line).to eq("Creature -- Dwarf Cleric")
  end

  it "has lifelink" do
    expect(story_seeker.lifelink?).to eq(true)
  end
end
