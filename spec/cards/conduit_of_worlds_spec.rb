require 'spec_helper'

RSpec.describe Magic::Cards::ConduitOfWorlds do
  include_context "two player game"

  let!(:conduit) { ResolvePermanent("Conduit of Worlds", owner: p1) }

  it "offers only nonland permanent cards from your graveyard" do
    bears = Card("Grizzly Bears", owner: p1)
    forest = Card("Forest", owner: p1)
    p1.graveyard.add(bears)
    p1.graveyard.add(forest)

    ability = conduit.activated_abilities.first

    expect(ability.target_choices).to contain_exactly(bears)
  end
end
