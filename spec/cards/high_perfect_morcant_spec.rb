# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HighPerfectMorcant do
  include_context "two player game"

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  let!(:rival_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a legendary 4/4 Elf Noble" do
    morcant = ResolvePermanent("High Perfect Morcant", owner: p1)
    game.choices.clear
    expect([morcant.power, morcant.toughness]).to eq([4, 4])
    expect(morcant.type?("Elf")).to eq(true)
    expect(morcant.type?("Legendary")).to eq(true)
  end

  describe "the enters trigger" do
    it "makes each opponent blight 1 when it enters" do
      ResolvePermanent("High Perfect Morcant", owner: p1)
      expect(game.choices.last).to be_a(Magic::Choice::Blight)
      expect(game.choices.last.player).to eq(p2)

      game.resolve_choice!(target: rival_bears)
      expect(minus_counters(rival_bears)).to eq(1)
    end

    it "triggers again when another Elf you control enters" do
      ResolvePermanent("High Perfect Morcant", owner: p1)
      game.resolve_choice!(target: rival_bears)

      ResolvePermanent("Wood Elves", owner: p1)
      expect(game.choices.last).to be_a(Magic::Choice::Blight)
    end

    it "ignores non-Elves and an opponent's Elves" do
      ResolvePermanent("High Perfect Morcant", owner: p1)
      game.resolve_choice!(target: rival_bears)

      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Wood Elves", owner: p2)
      expect(game.choices).to be_empty
    end

    it "does nothing when the opponent has no creature to blight" do
      rival_bears.destroy!
      ResolvePermanent("High Perfect Morcant", owner: p1)
      expect(game.choices).to be_empty
    end
  end

  describe "the proliferate ability" do
    # No creature for the opponent to blight, so the enters triggers leave nothing pending.
    before { rival_bears.destroy! }

    let!(:morcant) { ResolvePermanent("High Perfect Morcant", owner: p1) }
    let!(:elves) { 2.times.map { ResolvePermanent("Wood Elves", owner: p1) } }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before { go_to_main_phase! }

    it "taps three untapped Elves to proliferate" do
      bears.add_counter("+1/+1")
      p1.activate_ability(ability: morcant.activated_abilities.first) do |a|
        a.pay_multi_tap([morcant, *elves])
      end
      game.stack.resolve!

      expect([morcant, *elves]).to all(be_tapped)
      expect(game.choices.last).to be_a(Magic::Choice::Proliferate)
      game.resolve_choice!(chosen: [bears])
      expect(bears.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "can only be activated as a sorcery" do
      game.next_turn
      go_to_main_phase!
      expect(morcant.activated_abilities.first.requirements_met?).to eq(false)
    end
  end
end
