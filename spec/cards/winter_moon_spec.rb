# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WinterMoon do
  include_context "two player game"

  let!(:moon) { ResolvePermanent("Winter Moon", owner: p1) }

  def next_turns_untap!(turns)
    turns.times do
      current_turn.end!
      current_turn.cleanup!
      game.next_turn
      current_turn.untap!
    end
  end

  def tapped_lands(lands) = lands.select(&:tapped?)

  context "during your own untap step" do
    let!(:towers) { Array.new(3) { ResolvePermanent("Command Tower", owner: p1) } }
    let!(:forests) { Array.new(2) { ResolvePermanent("Forest", owner: p1) } }

    before { (towers + forests).each(&:tap!) }

    it "untaps only one nonbasic land" do
      next_turns_untap!(2)

      expect(tapped_lands(towers).count).to eq(2)
      expect(tapped_lands(forests).count).to eq(0)
    end

    it "does not limit basic lands" do
      next_turns_untap!(2)

      expect(forests).to all(be_untapped)
    end

    it "still untaps nonbasic lands when only one is tapped" do
      towers.drop(1).each(&:untap!)
      next_turns_untap!(2)

      expect(tapped_lands(towers)).to be_empty
    end
  end

  context "during an opponent's untap step" do
    let!(:their_towers) { Array.new(2) { ResolvePermanent("Command Tower", owner: p2) } }

    it "limits the opponent as well" do
      their_towers.each(&:tap!)
      next_turns_untap!(1)

      expect(tapped_lands(their_towers).count).to eq(1)
    end

    it "does not limit anyone once Winter Moon is gone" do
      their_towers.each(&:tap!)
      moon.destroy!
      game.settle!
      next_turns_untap!(1)

      expect(their_towers).to all(be_untapped)
    end
  end
end
