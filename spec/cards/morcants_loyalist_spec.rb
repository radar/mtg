# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MorcantsLoyalist do
  include_context "two player game"

  subject! { ResolvePermanent("Morcant's Loyalist", owner: p1) }

  it "is a 3/2 Elf Warrior" do
    expect(subject.power).to eq(3)
    expect(subject.toughness).to eq(2)
    expect(subject.type?("Elf")).to eq(true)
    expect(subject.type?("Warrior")).to eq(true)
  end

  context "static ability" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "gives other Elves you control +1/+1" do
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
    end

    it "does not give itself the boost" do
      expect(subject.power).to eq(3)
      expect(subject.toughness).to eq(2)
    end

    context "an Elf controlled by the opponent" do
      let!(:opponent_wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

      it "does not boost it" do
        expect(opponent_wood_elves.power).to eq(1)
        expect(opponent_wood_elves.toughness).to eq(1)
      end
    end

    context "a non-Elf creature you control" do
      let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

      it "does not boost it" do
        expect(grizzly_bears.power).to eq(2)
        expect(grizzly_bears.toughness).to eq(2)
      end
    end
  end

  context "dies" do
    context "with another Elf card in the graveyard" do
      let(:wood_elves) { Card("Wood Elves") }

      before { p1.graveyard.add(wood_elves) }

      it "returns it to hand" do
        subject.destroy!

        expect(wood_elves.zone).to eq(p1.hand)
      end
    end

    context "with multiple Elf cards in the graveyard" do
      let(:wood_elves) { Card("Wood Elves") }
      let(:elvish_archdruid) { Card("Elvish Archdruid") }

      before do
        p1.graveyard.add(wood_elves)
        p1.graveyard.add(elvish_archdruid)
      end

      it "lets the controller choose which one to return" do
        subject.destroy!
        game.resolve_choice!(target: elvish_archdruid)

        expect(elvish_archdruid.zone).to eq(p1.hand)
        expect(wood_elves.zone).to eq(p1.graveyard)
      end
    end

    context "with only its own card in the graveyard" do
      it "does not target itself" do
        subject.destroy!

        expect(subject.card.zone).to eq(p1.graveyard)
        expect(game.choices).to be_empty
      end
    end

    context "with a non-Elf card in the graveyard" do
      let(:grizzly_bears) { Card("Grizzly Bears") }

      before { p1.graveyard.add(grizzly_bears) }

      it "cannot target it" do
        subject.destroy!

        expect(grizzly_bears.zone).to eq(p1.graveyard)
      end
    end
  end
end
