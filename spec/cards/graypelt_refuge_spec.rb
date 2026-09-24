require "spec_helper"

RSpec.describe Magic::Cards::GraypeltRefuge do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) do
    p1.play_land(land: Card("Graypelt Refuge"))
    game.settle!
    p1.permanents.by_name("Graypelt Refuge").first
  end

  it "enters the battlefield tapped" do
    expect(permanent).to be_tapped
  end

  it "has the controller gain 1 life" do
    expect(p1.life).to eq(21)
  end

  it "taps for green or white, and nothing else" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:white) }
    expect(p1.mana_pool[:white]).to eq(1)

    permanent.untap!
    expect {
      p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:blue) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
