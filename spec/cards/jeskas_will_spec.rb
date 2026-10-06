# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JeskasWill do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Jeska's Will", owner: p1) }

  def cast(*modes)
    p1.hand.add(spell)
    p1.add_mana(red: 3)
    p1.cast(card: spell) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      modes.each { |mode, target| action.choose_mode(mode) { |m| m.targeting(target) if target } }
    end
    game.stack.resolve!
    game.settle!
  end

  def exile_permissions
    game.play_permissions.instance_variable_get(:@permissions).map(&:card)
  end

  it "adds {R} for each card in the opponent's hand" do
    p2.hand.add(Card("Forest", owner: p2))
    expected = p2.hand.count

    cast([described_class::AddMana, p2])

    expect(p1.mana_pool[:red]).to eq(expected)
  end

  it "exiles the top three cards, which may be played this turn" do
    top_three = p1.library.cards.first(3)

    cast([described_class::ExileTopThree, nil])

    expect(top_three.map(&:zone)).to all(be_exile)
    expect(exile_permissions).to include(*top_three)
  end

  it "allows only one mode without a commander" do
    expect(spell.modes_to_choose).to eq(1)
    expect do
      cast([described_class::AddMana, p2], [described_class::ExileTopThree, nil])
    end.to raise_error(Magic::Actions::Cast::InvalidModes)
  end

  context "with a commander on the battlefield" do
    before do
      p1.add_commander(Card("Lathril, Blade Of The Elves", owner: p1))
      ResolvePermanent("Lathril, Blade Of The Elves", owner: p1)
    end

    it "allows choosing one or both modes" do
      expect(spell.modes_to_choose).to eq(1..2)
    end

    it "does both" do
      p2.hand.add(Card("Forest", owner: p2))
      expected = p2.hand.count
      top = p1.library.cards.first

      cast([described_class::AddMana, p2], [described_class::ExileTopThree, nil])

      expect(p1.mana_pool[:red]).to eq(expected)
      expect(top.zone).to be_exile
    end
  end

  it "doesn't count a commander that isn't on the battlefield" do
    p1.add_commander(Card("Lathril, Blade Of The Elves", owner: p1))

    expect(spell.controls_commander?).to be false
  end
end
