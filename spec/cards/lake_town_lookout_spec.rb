# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LakeTownLookout do
  include_context "two player game"

  it "recruits when it dies" do
    lookout = ResolvePermanent("Lake Town Lookout", owner: p1)
    lookout.destroy!
    game.settle!
    spell = Card("Lake Town Lookout", owner: p1).tap { p1.hand.add(_1) }
    game.resolve_choice!(card: spell)
    expect(p1.creatures.map(&:name)).to include("Human Soldier")
  end
end
