# frozen_string_literal: true

require "spec_helper"

# "When you cast this spell, ...": `Card#cast_triggers` (TriggeredAbility::CastThisSpell subclasses), queued by
# Actions::Cast#perform. Shown with a probe trigger on a plain creature.
RSpec.describe "Cast triggers" do
  include_context "two player game"

  let(:log) { [] }

  let(:probe) do
    seen = log
    Class.new(Magic::TriggeredAbility::CastThisSpell) do
      define_method(:should_perform?) { spent(:blue) >= 2 }
      define_method(:call) do
        seen << [spell, mana_spent, controller]
        seen << :spell_still_on_stack if game.stack.spells.any? { _1.card == spell }
      end
    end
  end

  let(:creature) do
    Card("Glamermite", owner: p1).tap { |card| allow(card).to receive(:cast_triggers).and_return([probe]) }
  end

  before { go_to_main_phase! }

  it "fires when the card is cast, with the spell and the mana spent" do
    p1.add_mana(blue: 3)
    p1.cast(card: creature) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }

    expect(game.pending_triggers.size + game.stack.abilities.size).to eq(1)
    game.settle!

    expect(log.first).to eq([creature, { blue: 3 }, p1])
    expect(p1.creatures.map(&:name)).to include("Glamermite")
  end

  it "resolves above the spell it is cast with" do
    p1.add_mana(blue: 3)
    p1.cast(card: creature) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.tick!

    expect(game.stack.first).to be_a(probe)
    game.settle!

    expect(log.last).to eq(:spell_still_on_stack)
    expect(p1.creatures.map(&:name)).to include("Glamermite")
  end

  it "checks its intervening 'if' as the spell is cast" do
    p1.add_mana(blue: 1, red: 2)
    p1.cast(card: creature) { _1.pay_mana(generic: { red: 2 }, blue: 1) }
    game.settle!

    expect(log).to be_empty
    expect(p1.creatures.map(&:name)).to include("Glamermite")
  end

  it "does not fire when the permanent enters without being cast" do
    permanent = ResolvePermanent("Glamermite", owner: p1)
    game.settle!

    expect(permanent.card.cast_triggers).to eq([])
    expect(log).to be_empty
  end

  it "does not fire for a token copy of a cast spell" do
    allow_any_instance_of(Magic::Cards::Glamermite).to receive(:cast_triggers).and_return([probe])
    Magic::Permanent.token_copy(game: game, owner: p1, card: Card("Glamermite", owner: p1))
    game.settle!

    expect(log).to be_empty
  end
end
