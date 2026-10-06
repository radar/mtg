# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoltenGatekeeper do
  include_context "two player game"

  it "is a 2/3 artifact Golem" do
    gatekeeper = ResolvePermanent("Molten Gatekeeper", owner: p1)
    expect([gatekeeper.power, gatekeeper.toughness]).to eq([2, 3])
    expect(gatekeeper.type?("Artifact")).to be true
  end

  it "deals 1 damage to each opponent when another creature enters under your control" do
    ResolvePermanent("Molten Gatekeeper", owner: p1)

    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.to change { p2.life }.by(-1)
    expect { ResolvePermanent("Grizzly Bears", owner: p2) }.not_to change { p2.life }
  end

  context "unearth" do
    before { go_to_main_phase! }

    let(:card) { Card("Molten Gatekeeper", owner: p1) }

    before { p1.graveyard.add(card) }

    def unearth
      ability = card.graveyard_abilities.first
      p1.add_mana(red: 1)
      p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1) }
      game.stack.resolve!
      game.settle!
      p1.permanents.by_name("Molten Gatekeeper").first
    end

    it "returns it to the battlefield with haste" do
      gatekeeper = unearth

      expect(gatekeeper).not_to be_nil
      expect(gatekeeper).to have_keyword(:haste)
    end

    it "exiles it at the beginning of the end step" do
      unearth
      current_turn.end!
      game.settle!

      expect(card.zone).to be_exile
    end

    it "exiles it instead if it would die" do
      gatekeeper = unearth
      gatekeeper.destroy!
      game.settle!

      expect(card.zone).to be_exile
    end

    it "can only be activated as a sorcery" do
      ability = card.graveyard_abilities.first
      current_turn.end!
      p1.add_mana(red: 1)

      expect { p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1) } }.to raise_error(Magic::IllegalAction)
    end
  end
end
