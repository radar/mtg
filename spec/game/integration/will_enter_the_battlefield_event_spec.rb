require 'spec_helper'

RSpec.describe Magic::Game, "zone transitions -- will enter the battlefield event" do
  include_context "two player game"

  def will_enter_events
    current_turn.events.select { |event| event.is_a?(Magic::Events::WillEnterTheBattlefield) }
  end

  context "when a permanent enters the battlefield" do
    it "emits a will-enter checkpoint event before entering" do
      before_count = will_enter_events.count

      ResolvePermanent('Story Seeker', owner: p1, cast: false)

      expect(will_enter_events.count - before_count).to eq(1)
      event = will_enter_events.last
      expect(event.permanent.name).to eq('Story Seeker')
      expect(event.to).to be_battlefield
    end
  end

  context "when the entry is replaced by containment priest" do
    before do
      ResolvePermanent('Containment Priest', owner: p1)
    end

    it "does not emit a will-enter event for the replaced permanent" do
      before_count = will_enter_events.count

      ResolvePermanent('Story Seeker', owner: p2, cast: false)

      expect(will_enter_events.count).to eq(before_count)
      expect(game.exile.cards.map(&:name)).to include('Story Seeker')
    end
  end
end
