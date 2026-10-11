# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RestrictedOfficeLectureHall do
  include_context "two player game"

  before { go_to_main_phase! }

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  it "Restricted Office destroys all creatures with power 3 or greater when unlocked" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    mine = ResolvePermanent("Shroudstomper", owner: p1)
    theirs = ResolvePermanent("Baneslayer Angel", owner: p2)
    game.skip_choice! while game.choices.any?
    room = ResolvePermanent("Restricted Office Lecture Hall", doors: [:right])
    unlock(room, :left, white: 4)

    expect([mine.zone, theirs.zone]).to all(be_nil)
    expect(bears.zone).to be_battlefield
  end

  describe "Lecture Hall" do
    let!(:room) { ResolvePermanent("Restricted Office Lecture Hall", doors: [:right]) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { game.tick! }

    it "gives other permanents you control hexproof" do
      expect(bears).to have_keyword(:hexproof)
    end

    it "doesn't give itself or an opponent's permanents hexproof" do
      expect(room).not_to have_keyword(:hexproof)
      expect(theirs).not_to have_keyword(:hexproof)
    end
  end
end
