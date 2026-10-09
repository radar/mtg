# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BomburGentleDreamer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bombur) { ResolvePermanent("Bombur, Gentle Dreamer", owner: p1) }

  def to_next_untap_step
    2.times { game.next_turn }
    go_to_main_phase!
  end

  it "is a 5/3" do
    expect(bombur.power).to eq(5)
    expect(bombur.toughness).to eq(3)
  end

  it "does not untap during your untap step without an enduring story" do
    bombur.tap!
    to_next_untap_step
    expect(bombur).to be_tapped
  end

  it "untaps during your untap step with an enduring story" do
    p1.enduring_story = true
    bombur.tap!
    to_next_untap_step
    expect(bombur).to be_untapped
  end

  it "gets an enduring story from three legendaries and artifacts" do
    2.times { ResolvePermanent("Well-Worn Spatula", owner: p1) }
    bombur.tap!
    to_next_untap_step
    expect(bombur).to be_untapped
  end
end
