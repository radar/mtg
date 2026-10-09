# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThorinMountainKing do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:spatula_a) { ResolvePermanent("Well-Worn Spatula", owner: p1) }
  let!(:spatula_b) { ResolvePermanent("Well-Worn Spatula", owner: p1) }

  def enter_thorin
    thorin = ResolvePermanent("Thorin, Mountain King", owner: p1)
    game.settle!
    thorin
  end

  it "is a 3/4 with trample" do
    thorin = enter_thorin
    expect([thorin.power, thorin.toughness]).to eq([3, 4])
    expect(thorin).to have_keyword(:trample)
  end

  it "attaches the chosen Equipment to a creature and that creature damages a creature" do
    enter_thorin
    game.resolve_choice!(target: bears)
    game.resolve_choice!(targets: [spatula_a, spatula_b])
    game.tick!

    expect(bears.attachments).to contain_exactly(spatula_a, spatula_b)
    expect(bears.power).to eq(4)

    game.resolve_choice!(target: theirs)

    expect(theirs.card.zone).to be_graveyard
  end

  it "may attach no Equipment, so nothing deals damage" do
    enter_thorin
    game.resolve_choice!(target: bears)
    game.resolve_choice!(targets: [])

    expect(bears.attachments).to be_empty
    expect(game.choices).to be_empty
  end

  it "may choose no creature to damage" do
    enter_thorin
    game.resolve_choice!(target: bears)
    game.resolve_choice!(targets: [spatula_a])
    game.skip_choice!

    expect(theirs.damage).to eq(0)
  end
end
