# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SwabGoblin do
  include_context "two player game"

  it "is a 2/2 Goblin Pirate" do
    goblin = ResolvePermanent("Swab Goblin", owner: p1)

    expect([goblin.power, goblin.toughness]).to eq([2, 2])
  end
end
