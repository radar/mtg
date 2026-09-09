require "spec_helper"

RSpec.describe Magic::Cards::GisaGloriousResurrector do
  include_context "two player game"

  it "exiles opposing creatures instead of putting them in a graveyard" do
    gisa = ResolvePermanent("Gisa, Glorious Resurrector", owner: p1)
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    creature.destroy!

    expect(creature.card.zone).to be_exile
    expect(gisa).to be_creature
  end

  it "does not replace returning an opposing creature to hand" do
    ResolvePermanent("Gisa, Glorious Resurrector", owner: p1)
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    creature.return_to_hand

    expect(creature.card.zone).to be_hand
  end
end