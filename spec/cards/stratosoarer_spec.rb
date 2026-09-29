# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Stratosoarer do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 3/5 flying Elemental" do
    soarer = ResolvePermanent("Stratosoarer", owner: p1, cast: false)

    expect([soarer.power, soarer.toughness]).to eq([3, 5])
    expect(soarer).to be_flying
  end

  it "gives target creature flying until end of turn when it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Stratosoarer", owner: p1)
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears).to be_flying
  end

  it "the flying wears off at end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Stratosoarer", owner: p1)
    game.resolve_choice!(target: bears)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears).not_to be_flying
  end

  it "has basic landcycling {1}{U}" do
    card = Card("Stratosoarer", owner: p1)
    p1.hand.add(card)
    p1.library.add(Card("Island", owner: p1))
    p1.add_mana(blue: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { blue: 1 }, blue: 1) }
    island = p1.library.basic_lands.first
    game.choices.last.resolve!(targets: [island])

    expect(card.zone).to be_graveyard
    expect(island.zone).to be_hand
  end
end
