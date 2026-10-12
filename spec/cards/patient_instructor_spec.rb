# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PatientInstructor do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_instructor
    card = Card("Patient Instructor", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.settle!
    card
  end

  def soldiers = p1.creatures.select { _1.name == "Human Soldier" }

  it "is a 2/2 with vigilance" do
    card = ResolvePermanent("Patient Instructor", owner: p1)
    game.settle!
    game.choices.last&.resolve!(card: p1.hand.cards.first)

    expect([card.power, card.toughness]).to eq([2, 2])
    expect(card.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
  end

  it "draws then discards, making a Human Soldier if a nonland card was discarded" do
    cast_instructor
    nonland = Card("Grizzly Bears", owner: p1)
    p1.hand.add(nonland)
    hand_size = p1.hand.count
    game.resolve_choice!(card: nonland)

    expect(p1.hand.count).to eq(hand_size - 1)
    expect(nonland.zone).to be_graveyard
    expect(soldiers.count).to eq(1)
  end

  it "makes no token if a land was discarded" do
    cast_instructor
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    game.resolve_choice!(card: land)

    expect(soldiers).to be_empty
  end
end
