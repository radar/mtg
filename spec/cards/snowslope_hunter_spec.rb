# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SnowslopeHunter do
  include_context "two player game"

  let!(:hunter) { ResolvePermanent("Snowslope Hunter", owner: p1) }
  let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { go_to_main_phase! }

  def activate(sacrifice)
    p1.activate_ability(ability: hunter.activated_abilities.first) { |a| a.pay_sacrifice(sacrifice) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/3 Goblin Ranger" do
    expect([hunter.power, hunter.toughness]).to eq([2, 3])
  end

  it "sacrifices another creature to exile the top card, which you may play" do
    top = p1.library.first
    activate(fodder)

    expect(fodder.card.zone).to be_graveyard
    expect(game.exile.cards).to include(top)
    expect(game.play_permissions.permits?(top, p1)).to be(true)
  end

  it "can sacrifice an artifact instead" do
    stone = ResolvePermanent("Mind Stone", owner: p1)
    top = p1.library.first
    activate(stone)

    expect(stone.card.zone).to be_graveyard
    expect(game.exile.cards).to include(top)
  end

  it "can't sacrifice itself" do
    expect { activate(hunter) }.to raise_error(StandardError)
  end

  it "can be activated only once each turn" do
    activate(fodder)
    second = ResolvePermanent("Mind Stone", owner: p1)

    expect { activate(second) }.to raise_error(Magic::IllegalAction)
  end

  it "can be activated only during your turn" do
    go_to_main_phase_for!(p2)

    expect { activate(fodder) }.to raise_error(StandardError)
  end
end
