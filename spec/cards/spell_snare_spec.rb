# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpellSnare do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:snare) { Card("Spell Snare", owner: p2) }

  def cast_spell(name, mana)
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(**mana)
    action = p1.cast(card: card) { _1.pay_mana(**mana_payment(mana)) }
    [card, action]
  end

  def mana_payment(mana) = mana.key?(:green) && mana[:green] == 2 ? { generic: { green: 1 }, green: 1 } : { generic: { green: 1 } }

  def snare_targeting(action)
    p2.add_mana(blue: 1)
    p2.cast(card: snare) do
      _1.pay_mana(blue: 1)
      _1.targeting(action)
    end
  end

  it "counters a spell with mana value 2" do
    bears, action = cast_spell("Grizzly Bears", green: 2)
    snare_targeting(action)
    game.stack.resolve!

    expect(bears.zone).to be_graveyard
    expect(game.battlefield.creatures.map(&:name)).not_to include("Grizzly Bears")
  end

  it "can't target a spell with a different mana value" do
    _sol_ring, action = cast_spell("Sol Ring", green: 1)
    expect { snare_targeting(action) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
