# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NullpriestOfOblivion do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:priest) { Card("Nullpriest Of Oblivion", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:regrower) { Card("Elvish Regrower", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }

  def cast_priest(kicked:)
    p1.hand.add(priest)
    p1.add_mana(black: 6)
    action = cast_action(card: priest, player: p1)
    action.pay_mana(black: 1, generic: { black: 1 })
    action.pay_kicker(black: 1, generic: { black: 3 }) if kicked
    game.take_action(action)
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/1 with lifelink and menace" do
    permanent = ResolvePermanent("Nullpriest Of Oblivion", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 1])
    expect(permanent.has_keyword?(:lifelink)).to eq(true)
    expect(permanent.has_keyword?(:menace)).to eq(true)
  end

  it "returns any creature card from your graveyard to the battlefield when kicked" do
    p1.graveyard.add(bears)
    p1.graveyard.add(regrower)
    cast_priest(kicked: true)
    game.resolve_choice!(target: regrower)

    expect(p1.creatures.map(&:card)).to include(priest, regrower)
    expect(bears.zone).to be_graveyard
  end

  it "does nothing when it wasn't kicked" do
    p1.graveyard.add(bears)
    cast_priest(kicked: false)

    expect(p1.creatures.map(&:card)).to contain_exactly(priest)
    expect(bears.zone).to be_graveyard
  end

  it "ignores noncreature cards and the opponent's graveyard" do
    p1.graveyard.add(bolt)
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    cast_priest(kicked: true)

    expect(p1.creatures.map(&:card)).to contain_exactly(priest)
    expect(p2.creatures).to be_empty
  end
end
