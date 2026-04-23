# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanctumOfAll do
  include_context "two player game"

  let!(:sanctum_of_all) { ResolvePermanent("Sanctum Of All") }

  it "is a legendary enchantment shrine" do
    expect(sanctum_of_all).to be_legendary
    expect(sanctum_of_all).to be_enchantment
    expect(sanctum_of_all.types).to include("Shrine")
  end

  context "at the beginning of your upkeep" do
    it "presents a may choice to search" do
      current_turn.untap!
      current_turn.upkeep!

      expect(game.choices.first).to be_a(described_class::MaySearchChoice)
    end

    context "when the player searches their library" do
      let(:shrine_in_library) { add_to_library("Sanctum Of Tranquil Light", player: p1) }

      before do
        shrine_in_library
        current_turn.untap!
        current_turn.upkeep!
      end

      it "can search library for a shrine and put it onto the battlefield" do
        game.resolve_choice! # resolve MaySearchChoice

        expect(game.choices.first).to be_a(described_class::LibrarySearchMayChoice)
        game.resolve_choice! # resolve LibrarySearchMayChoice

        expect(game.choices.first).to be_a(described_class::LibrarySearchChoice)
        game.resolve_choice!(target: shrine_in_library)

        expect(p1.permanents.by_type("Shrine").count).to eq(2)
      end

      it "can skip the library search" do
        game.resolve_choice! # resolve MaySearchChoice

        expect(game.choices.first).to be_a(described_class::LibrarySearchMayChoice)
        game.skip_choice! # skip LibrarySearchMayChoice

        expect(p1.permanents.by_type("Shrine").count).to eq(1)
      end
    end

    context "when the player searches their graveyard" do
      let!(:shrine_in_graveyard) do
        card = Card("Sanctum Of Tranquil Light", owner: p1)
        card.zone = p1.graveyard
        p1.graveyard.items << card
        card
      end

      before do
        current_turn.untap!
        current_turn.upkeep!
      end

      it "can search graveyard for a shrine and put it onto the battlefield" do
        game.resolve_choice! # resolve MaySearchChoice

        game.skip_choice! # skip LibrarySearchMayChoice

        expect(game.choices.first).to be_a(described_class::GraveyardSearchMayChoice)
        game.resolve_choice! # resolve GraveyardSearchMayChoice -> auto-resolves GraveyardSearchChoice (single target)

        expect(p1.permanents.by_type("Shrine").count).to eq(2)
      end
    end

    it "can skip the entire search" do
      current_turn.untap!
      current_turn.upkeep!

      game.skip_choice! # skip MaySearchChoice

      expect(p1.permanents.by_type("Shrine").count).to eq(1)
    end
  end

  context "additional trigger with six or more shrines" do
    let!(:calm_waters_1) { ResolvePermanent("Sanctum Of Calm Waters") }
    let!(:calm_waters_2) { ResolvePermanent("Sanctum Of Calm Waters") }
    let!(:calm_waters_3) { ResolvePermanent("Sanctum Of Calm Waters") }
    let!(:calm_waters_4) { ResolvePermanent("Sanctum Of Calm Waters") }
    let!(:calm_waters_5) { ResolvePermanent("Sanctum Of Calm Waters") }

    it "triggers other shrine abilities an additional time when controlling six or more shrines" do
      go_to_main_phase!

      # SanctumOfCalmWaters triggers on FirstMainPhase
      # With Sanctum of All + 5x SanctumOfCalmWaters = 6 shrines
      # Each calm waters triggers once normally, then Sanctum of All doubles it
      # So each calm waters triggers twice, giving 5 * 2 = 10 FirstMainPhase choices
      # Plus Sanctum of All's own upkeep choice was already resolved
      calm_waters_choices = game.choices.select { |c| c.is_a?(Magic::Cards::SanctumOfCalmWaters::Choice) }
      expect(calm_waters_choices.count).to eq(10)
    end

    context "with fewer than six shrines" do
      it "does not trigger additional times with only five shrines" do
        # Remove calm_waters_5 from play (we have 5 total: sanctum_of_all + 4 calm_waters)
        calm_waters_5.move_zone!(from: game.battlefield, to: calm_waters_5.controller.graveyard)

        go_to_main_phase!

        # With only 5 shrines, no doubling
        calm_waters_choices = game.choices.select { |c| c.is_a?(Magic::Cards::SanctumOfCalmWaters::Choice) }
        expect(calm_waters_choices.count).to eq(4)
      end
    end
  end
end
