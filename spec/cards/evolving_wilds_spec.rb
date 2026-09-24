require "spec_helper"

RSpec.describe Magic::Cards::EvolvingWilds do
  include_context "two player game"

  subject!(:wilds) { ResolvePermanent("Evolving Wilds", owner: p1) }

  def p1_library
    9.times.map { Card("Forest") }
  end

  it "sacrifices itself to search for a basic land, put onto the battlefield tapped" do
    p1.activate_ability(ability: wilds.activated_abilities.first)
    expect(p1.graveyard.by_name("Evolving Wilds").count).to eq(1)
    game.stack.resolve!

    choice = game.choices.last
    expect(choice.choices).to all(be_basic_land)
    game.resolve_choice!(targets: [choice.choices.first])

    forest = game.battlefield.permanents.by_name("Forest").first
    expect(forest).to be_tapped
    expect(p1.library).not_to include(forest.card)
  end

  it "can't be activated while tapped" do
    wilds.tap!
    expect { p1.activate_ability(ability: wilds.activated_abilities.first) }.to raise_error(Magic::IllegalAction)
  end
end
