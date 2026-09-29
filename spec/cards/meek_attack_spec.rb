# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeekAttack do
  include_context "two player game"

  let!(:meek_attack) { ResolvePermanent("Meek Attack", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p1) } # 2/2: total 4
  let!(:elves) { Card("Wood Elves", owner: p1) } # 1/1: total 2
  let!(:angel) { Card("Baneslayer Angel", owner: p1) } # 5/5: total 10

  before do
    [bears, elves, angel].each { p1.hand.add(_1) }
    go_to_main_phase!
  end

  def activate
    p1.add_mana(red: 2)
    p1.activate_ability(ability: meek_attack.activated_abilities.first) do |ability|
      ability.pay_mana(generic: { red: 1 }, red: 1)
    end
    game.stack.resolve!
  end

  it "may put a creature card with total power and toughness 5 or less from your hand onto the battlefield" do
    activate
    expect(game.choices.last).to be_a(described_class::MayChoice)
    game.resolve_choice!
    expect(game.choices.last.choices.to_a).to contain_exactly(bears, elves)

    game.resolve_choice!(target: bears)
    expect(bears.zone).to be_battlefield
    expect(angel.zone).to be_hand
  end

  it "gives that creature haste" do
    activate
    game.resolve_choice!
    game.resolve_choice!(target: bears)
    creature = p1.creatures.find { _1.card == bears }
    game.tick!

    expect(creature.has_keyword?(:haste)).to eq(true)
    expect(creature.summoning_sick?).to eq(false)
  end

  it "sacrifices that creature at the beginning of the next end step" do
    activate
    game.resolve_choice!
    game.resolve_choice!(target: bears)

    current_turn.end!
    game.settle!
    expect(bears.zone).to be_graveyard
  end

  it "does nothing when declined" do
    activate
    game.skip_choice!
    expect(bears.zone).to be_hand
    expect(game.choices).to be_empty
  end

  it "offers nothing when no creature card in hand is small enough" do
    [bears, elves].each(&:discard!)
    activate
    game.resolve_choice!
    expect(game.choices).to be_empty
    expect(angel.zone).to be_hand
  end

  it "costs {1}{R} each time" do
    activate
    game.skip_choice!
    expect { activate }.not_to raise_error
  end
end
