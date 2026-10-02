# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effect do
  let(:e) { Magic::CardParser::Effects }

  it "parses reveal-the-hand-and-choose-a-discard, with and without an excluded type" do
    duress = described_class.parse("Target opponent reveals their hand. You choose a noncreature, nonland card from it. That player discards that card.")
    expect(duress).to eq(e.const_get(:RevealHandDiscard).new(%w[Creature Land]))
    expect(duress.target_choices).to eq("game.opponents(controller)")
    pilfer = described_class.parse("Target opponent reveals their hand. You choose a nonland card from it. That player discards that card.")
    expect(pilfer.excluded_types).to eq(%w[Land])
    any = described_class.parse("Target opponent reveals their hand. You choose a card from it. That player discards that card.")
    expect(any.excluded_types).to eq([])
  end
end
