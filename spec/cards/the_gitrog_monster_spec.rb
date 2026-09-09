require "spec_helper"

RSpec.describe Magic::Cards::TheGitrogMonster do
  include_context "two player game"

  it "is a legendary deathtouch creature" do
    gitrog = ResolvePermanent("The Gitrog Monster", owner: p1)

    expect(gitrog).to be_legendary
    expect(gitrog).to be_deathtouch
  end
end