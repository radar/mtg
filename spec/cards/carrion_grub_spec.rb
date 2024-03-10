require "spec_helper"

RSpec.describe Magic::Cards::CarrionGrub do
  include_context "two player game"

  before do
    5.times { p1.library.add(Card("Forest")) }
  end

  subject! { ResolvePermanent("Carrion Grub", owner: p1) }

  it "on ETB, p1 mills 4 cards" do
    mill_events = game.current_turn.events.count { _1.is_a?(Magic::Events::CardMilled) }
    expect(mill_events).to eq(4)
  end

  context "when Celestial Enforcer is in the graveyard" do
    before do
      p1.graveyard.add(Card("Celestial Enforcer"))
    end

    it "gets +2 from Celestial Enforcer" do
      expect(subject.power).to eq(2)
    end
  end

  context "when Wood Elves is in the graveyard" do
    before do
      p1.graveyard.add(Card("Wood Elves"))
    end

    it "gets +1 from Wood Elves" do
      expect(subject.power).to eq(1)
    end
  end
end
