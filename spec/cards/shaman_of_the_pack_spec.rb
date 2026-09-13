# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::ShamanOfThePack do
  include_context "two player game"

  let!(:shaman) { ResolvePermanent("Shaman Of The Pack", owner: p1) }

  it "is a 3/2 Elf Shaman" do
    expect(shaman.power).to eq(3)
    expect(shaman.toughness).to eq(2)
    expect(shaman.card.types).to include("Elf")
    expect(shaman.card.types).to include("Shaman")
  end

  context "when it enters the battlefield" do
    it "adds a life loss choice targeting only opponents" do
      choice = game.choices.first
      expect(choice).to be_a(described_class::LifeLossChoice)
      expect(choice.choices).to eq([p2])
    end

    it "the target opponent loses life equal to the number of Elves the controller controls (itself included)" do
      game.resolve_choice!(target: p2)
      expect(p2.life).to eq(19)
    end
  end

  context "when the controller controls additional Elves" do
    let!(:bloom_tender) { ResolvePermanent("Bloom Tender", owner: p1) }

    it "the target opponent loses life equal to the total number of Elves controlled" do
      game.resolve_choice!(target: p2)
      expect(p2.life).to eq(18)
    end
  end

  context "when the target opponent loses life" do
    it "does not affect the controller's own life total" do
      game.resolve_choice!(target: p2)
      expect(p1.life).to eq(20)
    end
  end
end
