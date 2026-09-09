require "spec_helper"

RSpec.describe Magic::Cards::AniktheaHandOfErebos do
  include_context "two player game"

  it "copies a non-Aura enchantment from the graveyard when it enters" do
    source = Card("Phyrexian Arena", owner: p1)
    p1.graveyard.add(source)
    anikthea = ResolvePermanent("Anikthea, Hand of Erebos", owner: p1)

    game.resolve_choice!(target: source)

    copies = game.battlefield.by_name("Phyrexian Arena")
    expect(copies.count).to eq(1)
    expect(anikthea).to be_legendary
  end
end