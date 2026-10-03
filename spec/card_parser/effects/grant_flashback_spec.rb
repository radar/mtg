# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::GrantFlashback do
  it "reads the two-sentence grant" do
    effect = Magic::CardParser::Effect.parse("Target instant or sorcery card in your graveyard gains flashback until end of turn. The flashback cost is equal to that card's mana cost.")
    expect(effect).to be_a(described_class)
    expect(effect.target_choices).to eq("controller.graveyard.cards.select { _1.instant? || _1.sorcery? }")
    expect(effect.resolve_call).to eq("target.grant_flashback_until_end_of_turn!")
  end

  it "reads an instant-only grant and ignores other flashback costs" do
    expect(Magic::CardParser::Effect.parse("Target instant card in your graveyard gains flashback until end of turn. The flashback cost is equal to that card's mana cost.").types).to eq(["instant"])
    expect(Magic::CardParser::Effect.parse("Target instant card in your graveyard gains flashback until end of turn. The flashback cost is {2}.")).to be_nil
  end
end
