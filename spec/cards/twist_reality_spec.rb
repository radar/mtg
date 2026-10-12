# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwistReality do
  include_context "two player game"

  let(:twist) { Card("Twist Reality", owner: p1).tap { p1.hand.add(_1) } }

  before { go_to_main_phase_for!(p2) }

  def cast_twist(mode, target = nil)
    p1.add_mana(blue: 3)
    p1.cast(card: twist) do |action|
      action.pay_mana(generic: { blue: 1 }, blue: 2)
      action.choose_mode(mode) { target ? _1.targeting(target) : _1 }
    end
    game.stack.resolve!
    game.settle!
  end

  it "counters target spell" do
    bears = Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) }
    p2.add_mana(green: 2)
    spell = p2.cast(card: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    cast_twist(described_class::CounterSpell, spell)

    expect(bears.zone).to be_graveyard
    expect(p2.creatures).to be_empty
  end

  it "can't target itself" do
    p1.add_mana(blue: 3)
    twist_action = p1.cast(card: twist) do |action|
      action.pay_mana(generic: { blue: 1 }, blue: 2)
      action.choose_mode(described_class::ManifestDread)
    end

    expect(game.stack.spells).to include(twist_action)
    expect(described_class::CounterSpell.new(game: game, card: twist).target_choices).not_to include(twist_action)
  end

  it "manifests dread" do
    cast_twist(described_class::ManifestDread)
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
    expect(twist.zone).to be_graveyard
  end
end
