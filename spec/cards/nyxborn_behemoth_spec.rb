require "spec_helper"

RSpec.describe Magic::Cards::NyxbornBehemoth do
  include_context "two player game"

  it "is a trampling enchantment creature" do
    behemoth = ResolvePermanent("Nyxborn Behemoth", owner: p1)

    expect(behemoth).to be_enchantment
    expect(behemoth).to be_creature
    expect(behemoth).to be_trample
  end
end