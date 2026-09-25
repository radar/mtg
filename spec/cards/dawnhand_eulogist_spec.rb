# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DawnhandEulogist do
  include_context "two player game"

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Island"),
      Card(top_elf ? "Llanowar Elves" : "Swamp"),
      Card("Plains"),
      Card("Mountain"),
    ]
  end

  let(:top_elf) { true }

  it "is a 3/3 Elf Warlock with menace" do
    eulogist = ResolvePermanent("Dawnhand Eulogist", owner: p1)
    expect(eulogist.power).to eq(3)
    expect(eulogist.toughness).to eq(3)
    expect(eulogist.type?("Elf")).to eq(true)
    expect(eulogist.type?("Warlock")).to eq(true)
    expect(eulogist).to have_keyword(:menace)
  end

  it "mills three cards when it enters" do
    expect { ResolvePermanent("Dawnhand Eulogist", owner: p1) }.to change { p1.graveyard.count }.by(3)
    expect(p1.library.count).to eq(1)
  end

  context "when an Elf card is milled" do
    it "drains each opponent for 2" do
      expect { ResolvePermanent("Dawnhand Eulogist", owner: p1) }
        .to change { p2.life }.by(-2)
        .and change { p1.life }.by(2)
    end
  end

  context "when an Elf card was already in the graveyard" do
    let(:top_elf) { false }

    it "drains each opponent for 2" do
      p1.graveyard.add(Card("Llanowar Elves"))
      expect { ResolvePermanent("Dawnhand Eulogist", owner: p1) }.to change { p2.life }.by(-2)
    end
  end

  context "when no Elf card is in the graveyard afterwards" do
    let(:top_elf) { false }

    it "does not drain" do
      ResolvePermanent("Dawnhand Eulogist", owner: p1)
      expect(p2.life).to eq(20)
      expect(p1.life).to eq(20)
    end
  end
end
