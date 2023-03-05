require 'spec_helper'

RSpec.describe Magic::Cards::OnakkeOgre do
  include_context "two player game"

  let!(:onakke_ogre) { ResolvePermanent("Onakke Ogre", owner: p1) }

  it "is an ogre warrior" do
    expect(onakke_ogre.card.type_line).to eq("Creature -- Ogre Warrior")
  end

end
