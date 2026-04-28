# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::AlpineHoundmaster do
  include_context "two player game"

  subject(:houndmaster) { ResolvePermanent("Alpine Houndmaster", owner: p1) }

  context "when entering the battlefield" do
    it "presents a may choice to search the library" do
      houndmaster
      expect(game.choices.last).to be_a(Magic::Cards::AlpineHoundmaster::MaySearchChoice)
    end

    context "when accepting the search" do
      let(:alpine_watchdog) { Card("Alpine Watchdog", owner: p1) }
      let(:igneous_cur) { Card("Igneous Cur", owner: p1) }

      before do
        p1.library.unshift(alpine_watchdog)
        p1.library.unshift(igneous_cur)
        houndmaster
      end

      it "shows Alpine Watchdog and Igneous Cur as choices" do
        game.resolve_choice!
        search_choice = game.choices.last
        expect(search_choice).to be_a(Magic::Cards::AlpineHoundmaster::SearchChoice)
        expect(search_choice.choices).to include(alpine_watchdog)
        expect(search_choice.choices).to include(igneous_cur)
      end

      it "puts selected cards into hand and shuffles library" do
        game.resolve_choice!
        game.resolve_choice!(targets: [alpine_watchdog, igneous_cur])
        expect(p1.hand).to include(alpine_watchdog)
        expect(p1.hand).to include(igneous_cur)
      end
    end

    context "when declining the search" do
      it "does not add a search choice" do
        houndmaster
        game.skip_choice!
        expect(game.choices.last).not_to be_a(Magic::Cards::AlpineHoundmaster::SearchChoice)
      end
    end
  end

  context "when attacking" do
    let!(:wood_elves_1) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:wood_elves_2) { ResolvePermanent("Wood Elves", owner: p1) }

    before do
      skip_to_combat!
    end

    it "gets +X/+0 where X is the number of other attacking creatures" do
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: houndmaster, target: p2)
      p1.declare_attacker(attacker: wood_elves_1, target: p2)
      p1.declare_attacker(attacker: wood_elves_2, target: p2)
      current_turn.attackers_declared!
      game.tick!

      expect(houndmaster.power).to eq(4)
      expect(houndmaster.toughness).to eq(3)
    end

    it "gets +1/+0 when one other creature attacks" do
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: houndmaster, target: p2)
      p1.declare_attacker(attacker: wood_elves_1, target: p2)
      current_turn.attackers_declared!
      game.tick!

      expect(houndmaster.power).to eq(3)
      expect(houndmaster.toughness).to eq(3)
    end

    it "gets no bonus when attacking alone" do
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: houndmaster, target: p2)
      current_turn.attackers_declared!
      game.tick!

      expect(houndmaster.power).to eq(2)
      expect(houndmaster.toughness).to eq(3)
    end
  end
end
