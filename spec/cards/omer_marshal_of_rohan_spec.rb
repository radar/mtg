# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OmerMarshalOfRohan do
  include_context "two player game"

  let(:trigger_class) { described_class::LegendaryAttackerDiedTrigger }

  before { go_to_main_phase! }

  let!(:eomer) { ResolvePermanent("Omer Marshal Of Rohan", owner: p1) }
  let!(:legend) { ResolvePermanent("Balmor Battlemage Captain", owner: p1) }
  let!(:legend2) { ResolvePermanent("Rosie Cotton Of South Lane", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  # Rosie's token-creation trigger can leave a pending choice behind; clear it so triggers can resolve.
  before { game.skip_choice! while game.choices.any? }

  def attack_with(*creatures, player: p1, target: p2)
    current_turn.beginning_of_combat! unless current_turn.step?(:beginning_of_combat)
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: target) }
    current_turn.attackers_declared!
    game.settle!
  end

  def triggers_queued
    [*game.pending_triggers, *game.stack.abilities].count { _1.is_a?(trigger_class) }
  end

  it "is a 4/4 legendary haste creature" do
    sick = ResolvePermanent("Omer Marshal Of Rohan", owner: p2, summoning_sick: true)
    expect(sick).to be_legendary
    expect([sick.power, sick.toughness]).to eq([4, 4])
    expect(sick.has_keyword?(Magic::Cards::Keywords::HASTE)).to eq(true)
  end

  context "when another attacking legendary creature you control dies" do
    before do
      skip_to_combat!
      attack_with(legend, bears)
    end

    it "untaps all creatures you control and adds an additional combat" do
      expect(bears).to be_tapped
      expect(current_turn.additional_combat_pending?).to eq(false)
      legend.destroy!
      game.settle!
      expect(bears).not_to be_tapped
      expect(current_turn.additional_combat_pending?).to eq(true)
      expect(game.choices).to be_empty
    end

  end

  context "grouping and the once-each-turn limit" do
    before do
      skip_to_combat!
      attack_with(legend, legend2, bears)
    end

    it "gives one trigger for two legendary creatures dying at the same time" do
      legend.destroy!
      legend2.destroy!
      expect(triggers_queued).to eq(1)
      game.settle!
    end

    it "does not trigger a second time this turn" do
      legend.destroy!
      game.settle!
      bears.tap!
      legend2.destroy!
      expect(triggers_queued).to eq(0)
      game.settle!
      expect(bears).to be_tapped
      expect(game.choices).to be_empty
    end
  end

  context "when it should not trigger" do
    before do
      skip_to_combat!
      bears.tap!
    end

    it "ignores a nonlegendary attacking creature dying" do
      attack_with(bears)
      bears.destroy!
      game.settle!
      expect(current_turn.additional_combat_pending?).to eq(false)
      expect(game.choices).to be_empty
    end

    it "ignores a legendary creature that is not attacking" do
      attack_with(bears)
      legend.destroy!
      game.settle!
      expect(current_turn.additional_combat_pending?).to eq(false)
      expect(legend2.tapped?).to eq(false)
      expect(bears).to be_tapped
    end

    it "ignores Éomer himself dying while attacking" do
      attack_with(eomer, bears)
      eomer.destroy!
      game.settle!
      expect(current_turn.additional_combat_pending?).to eq(false)
      expect(bears).to be_tapped
    end

    it "ignores a legendary attacker an opponent controls" do
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      go_to_main_phase_for!(p2)
      theirs = ResolvePermanent("Balmor Battlemage Captain", owner: p2)
      current_turn.beginning_of_combat!
      attack_with(theirs, target: p1)
      theirs.destroy!
      game.settle!
      expect(current_turn.additional_combat_pending?).to eq(false)
    end
  end
end
