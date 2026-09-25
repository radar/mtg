# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlenElendrasAnswer do
  include_context "two player game"

  let(:answer) { Card("Glen Elendra's Answer") }

  def cast_answer
    p1.add_mana(blue: 4)
    p1.cast(card: answer) { _1.auto_pay_mana }
  end

  def faeries = p1.creatures.select(&:token?)

  it "counters all spells and abilities opponents control, making a Faerie for each" do
    shock = Card("Shock", owner: p2)
    p2.hand.add(shock)
    p2.add_mana(red: 1)
    p2.cast(card: shock) do
      _1.pay_mana(red: 1)
      _1.targeting(p1)
    end
    cur = ResolvePermanent("Igneous Cur", owner: p2, settle: false)
    p2.add_mana(red: 2)
    p2.activate_ability(ability: cur.activated_abilities.first) { _1.pay_mana(generic: { red: 1 }, red: 1) }

    cast_answer
    game.stack.resolve!
    game.tick!

    expect(shock.zone).to be_graveyard
    expect(p1.life).to eq(20)
    expect(cur.power).to eq(1)
    expect(faeries.count).to eq(2)
    faerie = faeries.first
    expect(faerie.name).to eq("Faerie")
    expect([faerie.power, faerie.toughness]).to eq([1, 1])
    expect(faerie.colors).to contain_exactly(:blue, :black)
    expect(faerie).to be_flying
  end

  it "doesn't counter your own spells" do
    shock = Card("Shock", owner: p1)
    p1.hand.add(shock)
    p1.add_mana(red: 1)
    p1.cast(card: shock) do
      _1.pay_mana(red: 1)
      _1.targeting(p2)
    end

    cast_answer
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(faeries).to be_empty
  end

  it "makes no Faeries with nothing to counter" do
    cast_answer
    game.stack.resolve!
    expect(faeries).to be_empty
  end

  it "can't be countered" do
    cast_answer
    answer_cast = game.stack.first

    counterspell = Card("Counterspell", owner: p2)
    p2.hand.add(counterspell)
    p2.add_mana(blue: 2)
    p2.cast(card: counterspell) do
      _1.pay_mana(blue: 2)
      _1.targeting(answer_cast)
    end
    game.stack.resolve!

    expect(answer).not_to be_can_be_countered
    expect(answer.zone).to be_graveyard
    expect(game.current_turn.events.grep(Magic::Events::SpellCountered).map(&:spell)).not_to include(answer)
  end
end
