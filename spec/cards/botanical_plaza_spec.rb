require "spec_helper"

RSpec.describe Magic::Cards::BotanicalPlaza do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) do
    p1.play_land(land: Card("Botanical Plaza"))
    game.settle!
    p1.permanents.by_name("Botanical Plaza").first
  end

  it "enters the battlefield tapped" do
    expect(permanent).to be_tapped
  end

  it "taps for green or white, and nothing else" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) }
    expect(p1.mana_pool[:green]).to eq(1)

    permanent.untap!
    expect {
      p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:red) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end

  it "sacrifices itself to draw a card for {2}{G}{W}" do
    permanent.untap!
    p1.add_mana(green: 3, white: 1)
    expect do
      p1.activate_ability(ability: permanent.activated_abilities.last) { _1.pay_mana(generic: { green: 2 }, green: 1, white: 1) }
      game.stack.resolve!
    end.to change { p1.hand.count }.by(1)
    expect(p1.permanents.by_name("Botanical Plaza")).to be_empty
    expect(p1.graveyard.by_name("Botanical Plaza").count).to eq(1)
  end
end
