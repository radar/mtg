# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StriderRangerOfTheNorth do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:strider) { ResolvePermanent("Strider, Ranger Of The North", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:keybearer) { ResolvePermanent("Ghostly Keybearer", owner: p1) }

  def play_land!
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    p1.play_land(land: land)
    game.settle!
  end

  def choice = game.choices.first

  it "is a legendary 4/4 Human Ranger" do
    expect([strider.power, strider.toughness]).to eq([4, 4])
    expect(strider).to be_legendary
    expect(strider.type?("Human")).to eq(true)
    expect(strider.type?("Ranger")).to eq(true)
  end

  context "when a land you control enters" do
    before { play_land! }

    it "asks for a target creature" do
      expect(choice).to be_a(described_class::PumpChoice)
      expect(choice.choices).to contain_exactly(strider, bears, keybearer)
    end

    it "gives the target +1/+1 without first strike when its power stays below 4" do
      game.resolve_choice!(target: bears)
      game.tick!

      expect([bears.power, bears.toughness]).to eq([3, 3])
      expect(bears).not_to have_keyword(:first_strike)
    end

    it "gives first strike when the power is 4 or greater after the bonus" do
      game.resolve_choice!(target: keybearer)
      game.tick!

      expect([keybearer.power, keybearer.toughness]).to eq([4, 4])
      expect(keybearer).to have_keyword(:first_strike)
    end

    it "gives first strike to a creature that already has power 4" do
      game.resolve_choice!(target: strider)
      game.tick!

      expect([strider.power, strider.toughness]).to eq([5, 5])
      expect(strider).to have_keyword(:first_strike)
    end

    it "wears off at end of turn" do
      game.resolve_choice!(target: keybearer)
      game.tick!
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect([keybearer.power, keybearer.toughness]).to eq([3, 3])
      expect(keybearer).not_to have_keyword(:first_strike)
    end

    it "does not let the target be skipped, choosing a creature instead" do
      game.skip_choice!
      game.tick!

      expect(game.choices).to be_empty
      expect([strider.power, bears.power, keybearer.power].sum).to eq(4 + 2 + 3 + 1)
    end
  end

  context "targeting" do
    it "can target an opponent's creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      play_land!

      expect(choice.choices).to include(theirs)
    end

    it "cannot target a hexproof creature an opponent controls" do
      big = ResolvePermanent("Gigantic Big Bear", owner: p2)
      play_land!

      expect(choice.choices).not_to include(big)
      expect(choice.choices).to include(strider)
    end
  end

  context "when a land does not enter under your control" do
    it "does not trigger for an opponent's land" do
      ResolvePermanent("Forest", owner: p2)
      game.settle!

      expect(game.choices).to be_empty
      expect(strider.power).to eq(4)
    end

    it "does not trigger for a nonland permanent" do
      ResolvePermanent("Sol Ring", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
