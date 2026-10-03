# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ZulAshurLichLord do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:zul) { ResolvePermanent("Zul Ashur Lich Lord", owner: p1) }
  let(:ghoul) { Card("Diregraf Ghoul", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:their_ghoul) { Card("Diregraf Ghoul", owner: p2) }

  def activate(target)
    p1.activate_ability(ability: zul.activated_abilities.first) { |a| a.targeting(target) }
    game.stack.resolve!
  end

  it "is a 2/2 Zombie Warlock with ward-pay 2 life" do
    expect([zul.power, zul.toughness]).to eq([2, 2])
    expect(zul.type?("Zombie")).to eq(true)
  end

  it "lets you cast a Zombie creature card from your graveyard this turn" do
    p1.graveyard.add(ghoul)
    activate(ghoul)
    p1.add_mana(black: 1)
    p1.cast(card: ghoul) { |a| a.pay_mana(black: 1) }
    game.stack.resolve!

    expect(p1.creatures.map(&:card)).to include(ghoul)
    expect(zul).to be_tapped
  end

  it "doesn't let you cast it without the permission" do
    p1.graveyard.add(ghoul)
    p1.add_mana(black: 1)

    expect { p1.cast(card: ghoul) { |a| a.pay_mana(black: 1) } }.to raise_error(Magic::IllegalAction)
  end

  it "only lasts until end of turn" do
    p1.graveyard.add(ghoul)
    activate(ghoul)
    game.next_turn
    game.next_turn
    go_to_main_phase!
    p1.add_mana(black: 1)

    expect { p1.cast(card: ghoul) { |a| a.pay_mana(black: 1) } }.to raise_error(Magic::IllegalAction)
  end

  it "can't target a non-Zombie creature card or a card in an opponent's graveyard" do
    p1.graveyard.add(bears)
    p2.graveyard.add(their_ghoul)

    expect { activate(bears) }.to raise_error(RuntimeError, /Invalid target/)
    zul.untap!
    expect { activate(their_ghoul) }.to raise_error(RuntimeError, /Invalid target/)
  end
end
