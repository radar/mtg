require "spec_helper"

RSpec.describe Magic::Cards::TheGitrogMonster do
  include_context "two player game"

  it "is a legendary deathtouch creature" do
    gitrog = ResolvePermanent("The Gitrog Monster", owner: p1)

    expect(gitrog).to be_legendary
    expect(gitrog).to be_deathtouch
  end

  context "at the beginning of your upkeep" do
    let!(:gitrog) { ResolvePermanent("The Gitrog Monster", owner: p1) }

    def upkeep!
      current_turn.untap!
      current_turn.upkeep!
    end

    it "is sacrificed when you control no lands" do
      upkeep!

      expect(p1.creatures).not_to include(gitrog)
    end

    context "with a land" do
      let!(:forest) { ResolvePermanent("Forest", owner: p1) }

      it "sacrifices the land when you accept" do
        upkeep!
        game.resolve_choice!(sacrifice: forest)

        expect(p1.creatures).to include(gitrog)
        expect(p1.permanents).not_to include(forest)
      end

      it "sacrifices The Gitrog Monster when you decline" do
        upkeep!
        game.skip_choice!

        expect(p1.creatures).not_to include(gitrog)
        expect(p1.permanents).to include(forest)
      end
    end
  end
end