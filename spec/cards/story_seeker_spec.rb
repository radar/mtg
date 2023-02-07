require 'spec_helper'

RSpec.describe Magic::Cards::StorySeeker do
  include_context "two player game"

  let!(:story_seeker) { ResolvePermanent("Story Seeker", controller: p2) }

  it "has lifelink" do
    expect(story_seeker.lifelink?).to eq(true)
  end
end
