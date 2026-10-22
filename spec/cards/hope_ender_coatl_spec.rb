# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HopeEnderCoatl do
  include_context "two player game"

  let(:coatl) { Card("Hope-Ender Coatl", owner: p1) }
  let(:sol_ring) { Card("Sol Ring", owner: p2) }

  before { go_to_main_phase_for!(p2) }

  def cast_sol_ring
    p2.add_mana(red: 1)
    p2.cast(card: sol_ring) { _1.pay_mana(generic: { red: 1 }) }
  end

  def cast_coatl
    p1.add_mana(blue: 3)
    p1.cast(card: coatl) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
  end

  it "is a devoid flash flyer" do
    expect(coatl).to be_flash
    expect(coatl).to be_devoid
    expect(coatl.colors).to be_empty
    expect(coatl.has_keyword?(Magic::Cards::Keywords::FLYING)).to be(true)
  end

  it "puts its cast trigger above the spell, so the trigger resolves first" do
    cast_sol_ring
    cast_coatl

    top_first = game.stack.map { |item| item.is_a?(Magic::TriggeredAbility) ? item.class : item.card }
    expect(top_first).to eq([described_class::CastTrigger, coatl, sol_ring])
  end

  context "when the opponent's spell is on the stack" do
    before do
      cast_sol_ring
      cast_coatl
      game.stack.resolve! # the cast trigger
    end

    it "counters the spell outright if its controller can't pay {1}" do
      # Nothing to pay with: the choice is never offered.
      expect(game.choices.first).to be_nil
      expect(sol_ring.zone).to be_graveyard
    end

    it "lets Hope-Ender Coatl itself resolve after the trigger" do
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Hope-Ender Coatl")
    end
  end

  context "when the opponent can pay {1}" do
    before do
      cast_sol_ring
      cast_coatl
      p2.add_mana(red: 1)
      game.stack.resolve!
    end

    it "offers the opponent a payment, which saves the spell" do
      choice = game.choices.first
      expect(choice).to be_a(Magic::Choice::CounterUnlessPay)
      expect(choice.payer).to eq(p2)

      game.resolve_choice!(payment: { generic: { red: 1 } })
      game.settle!

      expect(p2.mana_pool[:red]).to eq(0)
      expect(p2.permanents.map(&:name)).to include("Sol Ring")
      expect(p1.creatures.map(&:name)).to include("Hope-Ender Coatl")
    end

    it "counters the spell if they decline" do
      game.skip_choice!
      game.settle!

      expect(sol_ring.zone).to be_graveyard
      expect(p2.mana_pool[:red]).to eq(1)
    end
  end

  context "with two opponent spells on the stack" do
    let(:mind_stone) { Card("Opt", owner: p2) }

    before do
      cast_sol_ring
      p2.add_mana(blue: 1)
      p2.cast(card: mind_stone) { _1.pay_mana(blue: 1) }
      cast_coatl
      game.stack.resolve! # the cast trigger
    end

    it "offers only the opponent's spells, and counters the chosen one" do
      choice = game.choices.first
      expect(choice.choices.map(&:card)).to contain_exactly(sol_ring, mind_stone)

      game.resolve_choice!(target: choice.choices.find { _1.card == mind_stone })
      game.settle!

      expect(mind_stone.zone).to be_graveyard
      expect(p2.permanents.map(&:name)).to include("Sol Ring")
    end

    it "still counters one spell when the choice is skipped" do
      game.skip_choice!
      game.settle!

      expect([sol_ring, mind_stone].count { _1.zone.graveyard? }).to eq(1)
    end
  end

  it "does nothing without an opponent's spell on the stack, but still resolves" do
    cast_coatl
    game.settle!

    expect(game.choices).to be_empty
    expect(p1.creatures.map(&:name)).to include("Hope-Ender Coatl")
  end

  it "does not trigger when it enters the battlefield without being cast" do
    cast_sol_ring
    ResolvePermanent("Hope-Ender Coatl", owner: p1, settle: false)

    expect(game.stack.abilities).to be_empty
    expect(game.pending_triggers).to be_empty
    expect(game.stack.spells.map(&:card)).to eq([sol_ring])
  end
end
