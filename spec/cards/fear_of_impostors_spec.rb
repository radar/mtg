# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfImpostors do
  include_context "two player game"

  let(:impostors) { Card("Fear Of Impostors", owner: p1).tap { p1.hand.add(_1) } }

  before { go_to_main_phase_for!(p2) }

  def opponent_casts(name)
    card = Card(name, owner: p2).tap { p2.hand.add(_1) }
    p2.add_mana(red: 1)
    [card, p2.cast(card: card) { _1.pay_mana(red: 1) }]
  end

  def flash_in_impostors
    p1.add_mana(blue: 3)
    p1.cast(card: impostors) { _1.pay_mana(generic: { blue: 1 }, blue: 2) }
    game.stack.resolve_top!
    game.settle!
  end

  it "is a 3/2 flash enchantment creature" do
    permanent = ResolvePermanent("Fear Of Impostors", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([3, 2])
    expect(permanent.card).to be_enchantment
    expect(permanent.card).to have_keyword(:flash)
  end

  it "counters target spell and its controller manifests dread" do
    bolt, = opponent_casts("Lightning Bolt")
    flash_in_impostors

    # With a single spell on the stack the target is automatic.
    expect(bolt.zone).to be_graveyard
    manifest = game.choices.last
    expect(manifest).to be_a(Magic::Choice::ManifestDread)
    expect(manifest.player).to eq(p2)
    game.resolve_choice!(target: manifest.choices.first)
    expect(p2.permanents.count(&:face_down?)).to eq(1)
  end

  it "does nothing when there is no spell to counter" do
    ResolvePermanent("Fear Of Impostors", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
  end
end
