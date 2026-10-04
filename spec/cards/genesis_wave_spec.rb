# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GenesisWave do
  include_context "two player game"

  let(:wave) { Card("Genesis Wave", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }       # permanent, mana value 2
  let(:bolt) { Card("Boltwave", owner: p1) }             # not a permanent
  let(:regrower) { Card("Elvish Regrower", owner: p1) }  # permanent, mana value 4
  let(:below) { Card("Forest", owner: p1) }              # below the revealed cards when X = 3

  # Top of the library, in order: (a Forest, drawn for the turn), bears, bolt, regrower, below.
  before do
    [below, regrower, bolt, bears, Card("Forest", owner: p1)].each { p1.library.add(_1) }
    p1.hand.add(wave)
    go_to_main_phase!
  end

  def cast_wave(x:)
    p1.add_mana(green: 3 + x)
    p1.cast(card: wave, value_for_x: x) { |a| a.pay_mana(green: 3, x: { green: x }) }
    game.stack.resolve!
  end

  it "reveals the top X cards and offers the permanents with mana value X or less" do
    cast_wave(x: 3)
    choice = game.choices.last

    expect(choice).to be_a(Magic::Choice::PutOntoBattlefieldFromAmong)
    expect(choice.cards).to eq([bears, bolt, regrower])
    expect(choice.choices).to contain_exactly(bears)
  end

  it "puts the chosen cards onto the battlefield and the rest of the revealed cards into your graveyard" do
    cast_wave(x: 3)
    game.resolve_choice!(targets: [bears])

    expect(p1.creatures.map(&:card)).to contain_exactly(bears)
    expect([bolt, regrower].map(&:zone)).to all(be_graveyard)
    expect(below.zone).to be_library
  end

  it "may put none of them onto the battlefield" do
    cast_wave(x: 3)
    game.resolve_choice!(targets: [])

    expect(p1.creatures).to be_empty
    expect([bears, bolt, regrower].map(&:zone)).to all(be_graveyard)
  end

  it "can put any number of them onto the battlefield" do
    cast_wave(x: 4)
    game.resolve_choice!(targets: [bears, regrower])
    game.skip_choice! if game.choices.any? # Elvish Regrower's own enters trigger

    expect(p1.creatures.map(&:card)).to include(bears, regrower)
    expect(bolt.zone).to be_graveyard
  end

  it "rejects a card that isn't a permanent or has too high a mana value" do
    cast_wave(x: 3)

    expect { game.choices.last.resolve!(targets: [regrower]) }.to raise_error(ArgumentError)
    expect { game.choices.last.resolve!(targets: [bolt]) }.to raise_error(ArgumentError)
  end

  it "reveals nothing with X = 0" do
    cast_wave(x: 0)
    game.resolve_choice!(targets: [])

    expect(bears.zone).to be_library
    expect(p1.graveyard.cards).to contain_exactly(wave)
  end
end
