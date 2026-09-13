# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GalaGreeters do
  include_context "two player game"

  subject!(:greeters) { ResolvePermanent("Gala Greeters", owner: p1) }

  context "when another creature you control enters" do
    it "presents a choice of the three modes" do
      ResolvePermanent("Grizzly Bears", owner: p1)

      choice = game.choices.last
      expect(choice).to be_a(described_class::AllianceChoice)
      expect(choice.choices).to contain_exactly(
        described_class::AllianceChoice::COUNTER,
        described_class::AllianceChoice::TREASURE,
        described_class::AllianceChoice::LIFE,
      )
    end

    it "puts a +1/+1 counter on itself when that mode is chosen" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.resolve_choice!(mode: described_class::AllianceChoice::COUNTER)
      game.tick!

      expect(greeters.power).to eq(2)
      expect(greeters.toughness).to eq(2)
    end

    it "creates a tapped Treasure token when that mode is chosen" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.resolve_choice!(mode: described_class::AllianceChoice::TREASURE)

      treasures = p1.permanents.select { |permanent| permanent.name == "Treasure" }
      expect(treasures.count).to eq(1)
      expect(treasures.first).to be_tapped
    end

    it "gains 2 life when that mode is chosen" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.resolve_choice!(mode: described_class::AllianceChoice::LIFE)

      expect(p1.life).to eq(22)
    end

    it "does not offer a mode that was already chosen this turn" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.resolve_choice!(mode: described_class::AllianceChoice::LIFE)

      ResolvePermanent("Elderfang Ritualist", owner: p1)
      choice = game.choices.last

      expect(choice.choices).to contain_exactly(
        described_class::AllianceChoice::COUNTER,
        described_class::AllianceChoice::TREASURE,
      )
    end

    it "offers all three modes again on a later turn" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.resolve_choice!(mode: described_class::AllianceChoice::LIFE)

      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      current_turn.first_main!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.end_of_combat!
      current_turn.second_main!
      current_turn.end!
      current_turn.cleanup!

      ResolvePermanent("Elderfang Ritualist", owner: p1)
      choice = game.choices.last

      expect(choice.choices).to contain_exactly(
        described_class::AllianceChoice::COUNTER,
        described_class::AllianceChoice::TREASURE,
        described_class::AllianceChoice::LIFE,
      )
    end
  end

  context "when it itself enters" do
    it "does not present a choice" do
      expect(game.choices.last).to be_nil
    end
  end

  context "when another creature an opponent controls enters" do
    it "does not present a choice" do
      ResolvePermanent("Grizzly Bears", owner: p2)

      expect(game.choices.last).to be_nil
    end
  end

  context "when a noncreature permanent you control enters" do
    it "does not present a choice" do
      ResolvePermanent("Sol Ring", owner: p1)

      expect(game.choices.last).to be_nil
    end
  end
end
