# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SunBlessedHealer do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:healer) { Card("Sun Blessed Healer", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:regrower) { Card("Elvish Regrower", owner: p1) }
  let(:island) { Card("Island", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }
  let(:mind_stone) { Card("Mind Stone", owner: p1) }

  def cast_healer(kicked:)
    p1.hand.add(healer)
    p1.add_mana(white: 4)
    action = cast_action(card: healer, player: p1)
    action.pay_mana(white: 1, generic: { white: 1 })
    action.pay_kicker(white: 1, generic: { white: 1 }) if kicked
    game.take_action(action)
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/1 with lifelink" do
    permanent = ResolvePermanent("Sun Blessed Healer", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([3, 1])
    expect(permanent.has_keyword?(:lifelink)).to eq(true)
  end

  it "returns a nonland permanent card with mana value 2 or less when kicked" do
    p1.graveyard.add(bears)
    p1.graveyard.add(mind_stone)
    cast_healer(kicked: true)
    game.resolve_choice!(target: mind_stone)

    expect(p1.permanents.map(&:card)).to include(mind_stone)
    expect(bears.zone).to be_graveyard
  end

  it "doesn't offer lands, expensive permanents or instants" do
    [island, regrower, bolt].each { p1.graveyard.add(_1) }
    p1.graveyard.add(bears)
    cast_healer(kicked: true)

    # Grizzly Bears is the only legal target, so it is chosen for you
    expect(p1.creatures.map(&:card)).to contain_exactly(healer, bears)
    expect([island, regrower, bolt].map(&:zone)).to all(be_graveyard)
  end

  it "does nothing when it wasn't kicked" do
    p1.graveyard.add(bears)
    cast_healer(kicked: false)

    expect(p1.creatures.map(&:card)).to contain_exactly(healer)
  end
end
