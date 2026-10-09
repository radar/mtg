# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LakeTownMariners do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Lake Town Mariners", owner: p1) }

  it "is a 6/5 with vigilance and ward {2}" do
    mariners = ResolvePermanent("Lake Town Mariners", owner: p1)
    expect(mariners.power).to eq(6)
    expect(mariners.toughness).to eq(5)
    expect(mariners.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
  end

  describe "adventure: Gone Fishing" do
    let!(:land) { ResolvePermanent("Forest", owner: p1) }
    let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }

    before do
      p1.hand.add(card)
      p1.add_mana(blue: 4)
    end

    it "blinks two creatures and/or lands you control and exiles the card" do
      bear.add_counter("+1/+1")
      land.tap!
      p1.cast(card:, adventure: true) { |a| a.targeting(bear, land).pay_mana(generic: { blue: 3 }, blue: 1) }
      game.stack.resolve!
      new_bear = p1.permanents.by_name("Large Bear").first
      new_land = p1.permanents.by_name("Forest").first
      expect(new_bear).not_to equal(bear)
      expect(new_bear.power).to eq(5)
      expect(new_land).not_to be_tapped
      expect(card.zone).to be_exile
    end

    it "needs two different targets" do
      expect { p1.cast(card:, adventure: true) { |a| a.targeting(bear, bear) } }.to raise_error(StandardError)
    end

    it "cannot target an opponent's permanent" do
      theirs = ResolvePermanent("Large Bear", owner: p2)
      expect { p1.cast(card:, adventure: true) { |a| a.targeting(bear, theirs) } }.to raise_error(StandardError)
    end

    it "can be cast at instant speed" do
      current_turn.beginning_of_combat!
      expect { p1.cast(card:, adventure: true) { |a| a.targeting(bear, land).pay_mana(generic: { blue: 3 }, blue: 1) } }.not_to raise_error
    end
  end
end
