require 'spec_helper'

RSpec.describe Magic::Cards::LandTax do
  include_context "two player game"

  subject { ResolvePermanent("Land Tax") }

  before do
    subject
    3.times { p1.library.add(Card("Forest")) }
  end

  context "when p2 controls more lands than p1" do
    before do
      5.times { ResolvePermanent("Island", owner: p2) }
    end

    it "allows p1 to search for 3 basic lands" do
      expect(game.choices).to be_empty
      turn_1 = game.current_turn
      turn_1.untap!
      # At the beginning of your upkeep...
      turn_1.upkeep!

      expect(game.choices.first).to be_a(Magic::Cards::LandTax::UpkeepChoice)
      choice = game.choices.first
      choice.resolve!

      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::LandTax::SearchChoice)
      expect(p1.hand.by_name("Forest").count).to eq(7)

      choice.resolve!(targets: p1.library.basic_lands.first(3))

      expect(p1.hand.by_name("Forest").count).to eq(10)
    end
  end

  context "when p2 controls the same number of lands as p1" do
    before do
      3.times { ResolvePermanent("Island", owner: p2) }
      3.times { ResolvePermanent("Forest", owner: p1) }
    end

    it "does not allow p1 to search for 3 basic lands" do
      expect(game.choices).to be_empty
      turn_1 = game.current_turn
      turn_1.untap!
      # At the beginning of your upkeep...
      turn_1.upkeep!

      expect(game.choices).to be_empty
    end
  end
end
