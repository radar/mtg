# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LivingPhone do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:phone) { ResolvePermanent("Living Phone", owner: p1) }

  it "is a 2/1 artifact creature" do
    expect(phone.power).to eq(2)
    expect(phone.toughness).to eq(1)
    expect(phone).to be_artifact
    expect(phone).to be_creature
  end

  context "when it dies" do
    it "lets you take a creature with power 2 or less from the top five, the rest go to the bottom" do
      big = add_to_library("Terror Of The Peaks", player: p1)
      small = add_to_library("Wood Elves", player: p1)
      top_five = p1.library.first(5)
      expect(top_five).to include(big, small)

      phone.destroy!
      game.settle!
      expect(game.choices.first.choices).to include(small)
      expect(game.choices.first.choices).not_to include(big)
      game.resolve_choice!(target: small)

      expect(p1.hand.cards).to include(small)
      expect(p1.library.last(4)).to match_array(top_five - [small])
    end

    it "puts all five on the bottom without asking if there is no eligible creature" do
      top_five = p1.library.first(5)
      phone.destroy!
      game.settle!
      expect(game.choices).to be_empty
      expect(p1.library.last(5)).to match_array(top_five)
    end
  end
end
