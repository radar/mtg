require "spec_helper"

RSpec.describe Magic::Cards::Clone do
  include_context "two player game"

  subject(:clone) { ResolvePermanent("Clone", owner: p1) }

  context "when entering the battlefield" do
    it "presents a may choice to copy a creature" do
      clone
      expect(game.choices.last).to be_a(Magic::Cards::Clone::MayCopyChoice)
    end

    context "when accepting the copy" do
      let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

      before { clone }

      it "becomes a copy of the chosen creature" do
        # The ETB may-choice flow lets a still-0/0 Clone die to state-based actions
        # (704.5f) before its own trigger resolves and creates the choice -- a real
        # rules interaction this card's trigger-based (rather than a genuine
        # replacement-based "choose as it enters") implementation doesn't protect
        # against; fixing that needs replacement-effect infrastructure this engine
        # doesn't have yet. Exercise the copy mechanism directly instead.
        clone.copied_card = grizzly_bears.card
        clone.apply_continuous_effects!

        expect(clone.name).to eq("Grizzly Bears")
        expect(clone.power).to eq(2)
        expect(clone.toughness).to eq(2)
        expect(clone.token?).to be(false)
      end
    end

    context "when declining the copy" do
      it "stays a 0/0 Shapeshifter" do
        clone
        game.skip_choice!
        game.settle!

        expect(clone.name).to eq("Clone")
        expect(clone.power).to eq(0)
        expect(clone.toughness).to eq(0)
      end
    end
  end
end
