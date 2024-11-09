require 'spec_helper'

RSpec.describe Magic::Cards::OnakkeOgre do
  include_context "two player game"

  let!(:onakke_ogre) { ResolvePermanent("Onakke Ogre", owner: p1) }

  it "is an ogre warrior" do
    expect(onakke_ogre.card.types).to include("Ogre")
    expect(onakke_ogre.card.types).to include("Warrior")
    expect(onakke_ogre.card.types).to include("Creature")
  end

end
