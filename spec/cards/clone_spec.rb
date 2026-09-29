require "spec_helper"

RSpec.describe Magic::Cards::Clone do
  include_context "two player game"

  let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  subject(:clone) { ResolvePermanent("Clone", owner: p1) }

  context "when entering the battlefield" do
    it "presents a may choice to copy a creature" do
      clone

      expect(game.choices.last).to be_a(Magic::Cards::Clone::MayCopyChoice)
    end

    it "survives as a 0/0 while it is still choosing (state-based actions wait for the choice)" do
      clone
      game.settle!

      expect(clone.zone).to be_battlefield
    end

    context "when accepting the copy" do
      before do
        clone
        game.resolve_choice! # yes
        game.resolve_choice!(target: grizzly_bears)
        game.tick!
      end

      it "becomes a copy of the chosen creature" do
        expect(clone.name).to eq("Grizzly Bears")
        expect(clone.power).to eq(2)
        expect(clone.toughness).to eq(2)
        expect(clone.token?).to be(false)
        expect(clone.zone).to be_battlefield
      end
    end

    context "when declining the copy" do
      it "stays a 0/0 Shapeshifter and then dies to state-based actions" do
        clone
        game.skip_choice!
        game.settle!

        expect(game.battlefield.permanents).not_to include(clone)
        expect(clone.card.zone).to be_graveyard
      end
    end

    it "can't copy itself" do
      clone
      game.resolve_choice!

      expect(game.choices.last.choices).to contain_exactly(grizzly_bears)
    end
  end

  context "with no other creature to copy" do
    it "dies as a 0/0 without asking" do
      grizzly_bears.destroy!
      game.settle!
      clone
      game.settle!

      expect(game.choices).to be_empty
      expect(clone.card.zone).to be_graveyard
    end
  end
end
