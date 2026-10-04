# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SphinxOfForgottenLore do
  include_context "two player game"

  let!(:sphinx) { ResolvePermanent("Sphinx Of Forgotten Lore", owner: p1) }
  let(:lightning) { Card("Burst Lightning", owner: p1) }
  let(:other_instant) { Card("Burst Lightning", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(sphinx, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 3/3 flash flyer" do
    expect([sphinx.power, sphinx.toughness]).to eq([3, 3])
    expect(sphinx.has_keyword?(:flying)).to eq(true)
    expect(sphinx.card).to be_flash
  end

  it "gives an instant in your graveyard flashback for its mana cost when it attacks" do
    p1.graveyard.add(lightning)
    p1.graveyard.add(other_instant)
    attack!
    game.resolve_choice!(target: lightning)
    p1.add_mana(red: 1)

    action = cast_action(player: p1, card: lightning, flashback: true)
    action.pay_mana(red: 1).targeting(p2)
    game.take_action(action)
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(lightning.zone).to be_exile
  end

  it "doesn't let you flash back a card that wasn't chosen" do
    p1.graveyard.add(lightning)
    p1.graveyard.add(other_instant)
    attack!
    game.resolve_choice!(target: lightning)

    expect(cast_action(player: p1, card: other_instant, flashback: true).legal?).to eq(false)
  end

  it "lasts until end of turn only" do
    p1.graveyard.add(lightning)
    p1.graveyard.add(other_instant)
    attack!
    game.resolve_choice!(target: lightning)
    game.next_turn
    game.next_turn

    expect(cast_action(player: p1, card: lightning, flashback: true).legal?).to eq(false)
  end

  it "can't target a creature card or an opponent's graveyard" do
    p1.graveyard.add(bears)
    p2.graveyard.add(Card("Burst Lightning", owner: p2))
    p1.graveyard.add(lightning)
    p1.graveyard.add(other_instant)
    attack!

    expect(game.choices.last.choices).to contain_exactly(lightning, other_instant)
  end
end
