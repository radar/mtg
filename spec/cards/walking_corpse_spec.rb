require 'spec_helper'

RSpec.describe Magic::Cards::WalkingCorpse do
  include_context "two player game"

  let!(:walking_corpse) { ResolvePermanent("Walking Corpse", owner: p1) }

  it "is a zombie" do
    expect(walking_corpse.card.type_line).to eq("Creature -- Zombie")
  end
end
