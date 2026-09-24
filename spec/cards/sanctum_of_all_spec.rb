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
    # 5 copies of the same legendary Shrine would violate the legend rule (704.5j)
    # for real -- give each a distinct #name so the fixture can test shrine-count
    # doubling in isolation, as if they were 5 different (legendary) cycle members.
    let!(:calm_waters_1) { resolve_uniquely_named_shrine!("Sanctum Of Calm Waters", 1) }
    let!(:calm_waters_2) { resolve_uniquely_named_shrine!("Sanctum Of Calm Waters", 2) }
    let!(:calm_waters_3) { resolve_uniquely_named_shrine!("Sanctum Of Calm Waters", 3) }
    let!(:calm_waters_4) { resolve_uniquely_named_shrine!("Sanctum Of Calm Waters", 4) }
    let!(:calm_waters_5) { resolve_uniquely_named_shrine!("Sanctum Of Calm Waters", 5) }

    it "triggers other shrine abilities an additional time when controlling six or more shrines" do
      go_to_main_phase!

      # SanctumOfCalmWaters triggers on FirstMainPhase
      # With Sanctum of All + 5x SanctumOfCalmWaters = 6 shrines
      # Each calm waters triggers once normally, then Sanctum of All doubles it
      # So each calm waters triggers twice, giving 5 * 2 = 10 FirstMainPhase choices
      # Plus Sanctum of All's own upkeep choice was already resolved.
      # Each of those choices only exists one at a time now that triggers go on the
      # stack and resolve in order (rather than all firing synchronously up front),
      # so count them as they appear instead of expecting them all pending at once.
      expect(count_calm_waters_choices!).to eq(10)
    end

    context "with fewer than six shrines" do
      it "does not trigger additional times with only five shrines" do
        # Remove calm_waters_5 from play (we have 5 total: sanctum_of_all + 4 calm_waters)
        calm_waters_5.move_zone!(from: game.battlefield, to: calm_waters_5.controller.graveyard)

        go_to_main_phase!

        # With only 5 shrines, no doubling
        expect(count_calm_waters_choices!).to eq(4)
      end
    end
  end

  def resolve_uniquely_named_shrine!(card_name, suffix)
    permanent = ResolvePermanent(card_name)
    unique_name = "#{permanent.name} (#{suffix})"
    permanent.define_singleton_method(:name) { unique_name }
    permanent
  end

  def count_calm_waters_choices!
    count = 0
    loop do
      game.check_state_based_actions!
      if game.stack.pending_choices?
        choice = game.choices.first
        count += 1 if choice.is_a?(Magic::Cards::SanctumOfCalmWaters::Choice)
        game.skip_choice!
      elsif !game.stack.empty?
        game.stack.resolve!
      else
        break
      end
    end
    count
  end
end
