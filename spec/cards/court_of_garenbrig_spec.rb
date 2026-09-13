# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CourtOfGarenbrig do
  include_context "two player game"

  let!(:court) { ResolvePermanent("Court of Garenbrig", owner: p1) }

  it "makes its controller the monarch when it enters" do
    expect(p1.monarch?).to be true
  end

  context "at the beginning of the controller's upkeep" do
    before do
      2.times { game.next_turn }
    end

    it "offers to distribute two +1/+1 counters among up to two target creatures" do
      bear = ResolvePermanent("Grizzly Bears", owner: p1)
      go_to_upkeep!

      choice = game.choices.last
      expect(choice).to be_a(described_class::DistributeCountersChoice)
      expect(choice.choices).to include(bear)
    end

    context "when the monarch" do
      it "doubles the +1/+1 counters on each creature the controller controls after distributing" do
        bear = ResolvePermanent("Grizzly Bears", owner: p1)
        go_to_upkeep!

        game.resolve_choice!(distribution: { bear => 2 })
        game.tick!

        # bear started with 0 counters, gets 2 from distribution, then doubled (since
        # controller is still the monarch) to 4 total +1/+1 counters.
        expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(4)
      end

      it "also doubles pre-existing +1/+1 counters on other creatures the controller controls" do
        bear = ResolvePermanent("Grizzly Bears", owner: p1)
        other = ResolvePermanent("Llanowar Elves", owner: p1)
        other.add_counter("+1/+1", amount: 3)
        go_to_upkeep!

        game.resolve_choice!(distribution: { bear => 1 })
        game.tick!

        expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
        expect(other.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(6)
      end
    end

    context "when not the monarch" do
      before { game.make_monarch!(p2) }

      it "distributes the counters but does not double them" do
        bear = ResolvePermanent("Grizzly Bears", owner: p1)
        go_to_upkeep!

        game.resolve_choice!(distribution: { bear => 2 })
        game.tick!

        expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
      end
    end

    it "can distribute counters to an opponent's creature" do
      opposing_bear = ResolvePermanent("Grizzly Bears", owner: p2)
      go_to_upkeep!

      choice = game.choices.last
      expect(choice.choices).to include(opposing_bear)

      game.resolve_choice!(distribution: { opposing_bear => 2 })
      game.tick!

      expect(opposing_bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end
  end

  def go_to_upkeep!
    current_turn.untap!
    current_turn.upkeep!
  end
end
