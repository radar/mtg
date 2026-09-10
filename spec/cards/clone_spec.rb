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
        game.resolve_choice!
        game.resolve_choice!(target: grizzly_bears)
        game.tick!

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
        game.tick!

        expect(clone.name).to eq("Clone")
        expect(clone.power).to eq(0)
        expect(clone.toughness).to eq(0)
      end
    end
  end
end
