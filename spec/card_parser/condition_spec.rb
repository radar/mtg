# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Condition do
  it "checks what you control" do
    expect(described_class.parse("you control an artifact")).to eq("controller.artifacts.any?")
    expect(described_class.parse("you control another Elf")).to eq('controller.permanents.by_type("Elf").except(source).any?')
    expect(described_class.parse("you control three or more creatures")).to eq("controller.creatures.count >= 3")
    expect(described_class.parse("you control two or more Elves")).to eq('controller.permanents.by_type("Elf").count >= 2')
  end

  it "checks the turn and your hand" do
    expect(described_class.parse("it's your turn")).to eq("game.current_turn.active_player == controller")
    expect(described_class.parse("you have no cards in hand")).to eq("controller.hand.empty?")
  end

  it "doesn't parse other conditions" do
    expect(described_class.parse("you have 30 or more life")).to be_nil
  end
end
