# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SawbladeSkinripper do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:skinripper) { ResolvePermanent("Sawblade Skinripper", owner: p1) }
  let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def sacrifice!(permanent)
    p1.add_mana(red: 2)
    p1.activate_ability(ability: skinripper.activated_abilities.first) do
      _1.pay_mana(generic: { red: 2 })
      _1.pay_sacrifice(permanent)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/2 menace Human Assassin" do
    expect([skinripper.power, skinripper.toughness]).to eq([3, 2])
    expect(skinripper).to be_menace
  end

  it "puts a +1/+1 counter on itself when you sacrifice another creature" do
    sacrifice!(fodder)

    expect(skinripper.power).to eq(4)
    expect(p1.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])
  end

  it "can't sacrifice itself" do
    expect { sacrifice!(skinripper) }.to raise_error(StandardError)
  end

  it "deals damage equal to the permanents sacrificed this turn at your end step" do
    sacrifice!(fodder)
    current_turn.end!
    game.choices.last.resolve!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "does nothing at the end step if you sacrificed nothing" do
    current_turn.end!

    expect(game.choices).to be_empty
  end
end
