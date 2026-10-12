# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnwantedRemake do
  include_context "two player game"

  let(:spell) { Card("Unwanted Remake", owner: p1).tap { p1.hand.add(_1) } }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_on(target)
    p1.add_mana(white: 1)
    p1.cast(card: spell) { _1.pay_mana(white: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "destroys target creature, and its controller manifests dread" do
    cast_on(bears)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::ManifestDread)
    expect(choice.player).to eq(p2)
    expect(choice.chooser).to eq(p2)

    game.resolve_choice!(target: choice.choices.first)
    expect(p2.permanents.count(&:face_down?)).to eq(1)
    expect(p1.permanents.count(&:face_down?)).to eq(0)
  end

  it "makes you manifest dread when you destroy your own creature" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_on(mine)

    expect(game.choices.last.player).to eq(p1)
  end

  it "still has the creature's controller manifest dread when the creature isn't destroyed" do
    survivor = ResolvePermanent("Grizzly Bears", owner: p2)
    allow(survivor).to receive(:destroy!).and_return(false)
    cast_on(survivor)

    expect(survivor.zone).to be_battlefield
    expect(game.choices.last.player).to eq(p2)
  end
end
