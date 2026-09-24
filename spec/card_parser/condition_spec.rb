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

  it "checks life totals, the graveyard and controlling none" do
    expect(described_class.parse("you have 30 or more life")).to eq("controller.life >= 30")
    expect(described_class.parse("an opponent has 10 or less life")).to eq("game.opponents(controller).any? { _1.life <= 10 }")
    expect(described_class.parse("there are seven or more cards in your graveyard")).to eq("controller.graveyard.cards.count >= 7")
    expect(described_class.parse("you control no other creatures")).to eq("controller.creatures.except(source).none?")
    expect(described_class.parse("it's not your turn")).to eq("game.current_turn.active_player != controller")
  end

  it "checks the permanent itself" do
    expect(described_class.parse("~ is tapped")).to eq("source.tapped?")
    expect(described_class.parse("~ is untapped")).to eq("source.untapped?")
    expect(described_class.parse("~ is equipped")).to eq('source.attachments.any? { _1.type?("Equipment") }')
  end

  it "doesn't parse other conditions" do
    expect(described_class.parse("you have 30 or more poison counters")).to be_nil
  end
end
