# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnnervingGrasp do
  include_context "two player game"

  let(:card) { Card("Unnerving Grasp", owner: p1).tap { p1.hand.add(_1) } }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:forest) { ResolvePermanent("Forest", owner: p2) }

  before { go_to_main_phase! }

  def cast(*targets)
    p1.add_mana(blue: 3)
    p1.cast(card: card) { _1.pay_mana(generic: { blue: 2 }, blue: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "returns target nonland permanent to its owner's hand, then manifests dread" do
    cast(bears)

    expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    expect(bears.zone).to be_nil
    game.resolve_choice!(target: game.choices.last.choices.first)
    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  it "may target nothing and still manifests dread" do
    cast

    expect(game.choices.last).to be_a(Magic::Choice::ManifestDread)
    expect(bears.zone).to be_battlefield
  end

  it "can't target a land" do
    expect { cast(forest) }.to raise_error(StandardError)
  end
end
