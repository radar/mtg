# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CardParser generated effects in play" do
  include_context "two player game"

  def load_card(text)
    result = Magic::CardParser.parse(text)
    const = Magic::CardGenerator.const_name(result.name)
    Magic::Cards.send(:remove_const, const) if Magic::Cards.const_defined?(const, false)
    # rubocop:disable Security/Eval
    eval(Magic::CardGenerator.generate(result))
    # rubocop:enable Security/Eval
    Magic::Cards.const_get(const)
  end

  # Pays a {N}{C} cost with mana of colour C only.
  def cast(name, color, generic)
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(color => generic + 1)
    p1.cast(card:) do |action|
      action.pay_mana(generic: { color => generic }, color => 1)
      yield action if block_given?
    end
    game.stack.resolve!
  end

  it "draws a card when a generated creature enters" do
    load_card("Parsed Visionary {1}{G}\nCreature — Elf Shaman\nWhen Parsed Visionary enters, draw a card.\n1/1\n")
    expect { ResolvePermanent("Parsed Visionary", owner: p1) }.to change { p1.hand.count }.by(1)
  end

  it "targets on entering, and runs the effects after the target once it is chosen" do
    load_card("Parsed Pup {2}{R}\nCreature — Dog\nWhen Parsed Pup enters, it deals 2 damage to any target. You gain 1 life.\n2/2\n")
    pup = ResolvePermanent("Parsed Pup", owner: p1)
    expect(game.choices.last).to be_a(pup.card.class::EntersTrigger::TargetChoice)

    game.resolve_choice!(target: p2)
    expect(p2.life).to eq(18)
    expect(p1.life).to eq(21)
  end

  it "scries then draws when a generated creature enters" do
    load_card("Parsed Seer {1}{U}\nCreature — Wizard\nWhen Parsed Seer enters, scry 1, then draw a card.\n1/1\n")
    ResolvePermanent("Parsed Seer", owner: p1)
    top = p1.library.first
    expect { game.resolve_choice!(bottom: [top]) }.to change { p1.hand.count }.by(1)
    expect(p1.library.last).to eq(top)
  end

  it "makes each opponent lose life when a generated creature enters" do
    load_card("Parsed Leech {B}\nCreature — Leech\nWhen Parsed Leech enters, each opponent loses 2 life.\n1/1\n")
    ResolvePermanent("Parsed Leech", owner: p1)
    expect(p2.life).to eq(18)
  end

  context "with generated spells" do
    before { go_to_main_phase! }

    it "creates tokens, then puts counters on each creature you control" do
      load_card("Parsed Watch {2}{W}\nSorcery\nCreate two 1/1 white Soldier creature tokens with vigilance.\n" \
                "Put a +1/+1 counter on each creature you control.\n")
      cast("Parsed Watch", :white, 2)

      soldiers = p1.creatures.select { _1.name == "Soldier" }
      expect(soldiers.size).to eq(2)
      expect(soldiers.map(&:power)).to eq([2, 2])
      expect(soldiers).to all(be_vigilant)
    end

    it "makes the target player discard" do
      load_card("Parsed Rot {2}{B}\nSorcery\nTarget player discards two cards.\n")
      cast("Parsed Rot", :black, 2) { _1.targeting(p2) }

      expect(game.choices.map(&:class)).to eq([Magic::Choice::Discard] * 2)
      expect(game.choices.map(&:player)).to eq([p2, p2])
    end

    it "exiles a creature an opponent controls and loses life" do
      load_card("Parsed End {1}{W}\nInstant\nExile target creature an opponent controls. You lose 2 life.\n")
      theirs = ResolvePermanent("Wood Elves", owner: p2)
      cast("Parsed End", :white, 1) { _1.targeting(theirs) }

      expect(theirs.card.zone).to be_exile
      expect(p1.life).to eq(18)
    end
  end
end
