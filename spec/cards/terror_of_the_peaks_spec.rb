# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::TerrorOfThePeaks do
  include_context "two player game"

  let!(:terror) { ResolvePermanent("Terror Of The Peaks", owner: p1) }

  it "is a 5/4 flying dragon" do
    expect(terror.power).to eq(5)
    expect(terror.toughness).to eq(4)
    expect(terror).to be_flying
    expect(terror.card.types).to include("Dragon")
  end

  context "when an opponent casts a spell targeting it" do
    before do
      p2.add_mana(red: 1)
      action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
      action.pay_mana(red: 1)
      action.targeting(terror)
      game.take_action(action)
    end

    it "the opponent loses 3 life" do
      expect(p2.life).to eq(17)
    end
  end

  context "when the controller casts a spell targeting it" do
    before do
      p1.add_mana(red: 2)
      action = cast_action(card: Card("Sure Strike", owner: p1), player: p1)
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.targeting(terror)
      game.take_action(action)
    end

    it "the controller does not lose life" do
      expect(p1.life).to eq(20)
    end
  end

  context "when another creature you control enters" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "adds a damage choice targeting any target" do
      choice = game.choices.first
      expect(choice).to be_a(described_class::DamageChoice)
      expect(choice.choices).to include(p2)
      expect(choice.choices).to include(wood_elves)
    end

    it "deals damage equal to the entering creature's power to the chosen target" do
      game.resolve_choice!(target: p2)
      expect(p2.life).to eq(19) # Wood Elves power = 1
    end
  end

  context "when an opponent's creature enters" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "does not trigger" do
      expect(game.choices).to be_empty
    end
  end
end
