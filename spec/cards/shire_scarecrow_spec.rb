# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShireScarecrow do
  include_context "two player game"

  let!(:scarecrow) { ResolvePermanent("Shire Scarecrow", owner: p1) }

  def ability = scarecrow.activated_abilities.first

  def activate(color = :black)
    p1.activate_ability(ability: ability) do
      _1.pay_mana(generic: { red: 1 })
      _1.choose(color)
    end
  end

  # The once-each-turn record is cleared in the cleanup step.
  def next_turn_cleanup
    current_turn.end!
    current_turn.cleanup!
  end

  it "is a 0/3 artifact creature with defender" do
    expect([scarecrow.power, scarecrow.toughness]).to eq([0, 3])
    expect(scarecrow.artifact?).to eq(true)
    expect(scarecrow.type?("Scarecrow")).to eq(true)
    expect(scarecrow.has_keyword?(Magic::Cards::Keywords::DEFENDER)).to eq(true)
  end

  it "adds one mana of the chosen color for {1}" do
    p1.add_mana(red: 1)
    activate(:blue)

    expect(p1.mana_pool[:blue]).to eq(1)
    expect(p1.mana_pool[:red]).to eq(0)
    expect(p1.mana_pool.values.sum).to eq(1)
  end

  it "can be activated for any color" do
    %i[white blue black red green].each do |color|
      p1.add_mana(red: 1)
      activate(color)
      expect(p1.mana_pool[color]).to eq(1)
      next_turn_cleanup
    end
  end

  it "can't be activated without {1} to pay" do
    expect { activate }.to raise_error(StandardError)
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "can't be activated twice in one turn" do
    p1.add_mana(red: 2)
    activate(:green)

    expect { activate(:green) }.to raise_error(Magic::IllegalAction)
    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "can be activated again on a later turn" do
    p1.add_mana(red: 2)
    activate(:green)
    next_turn_cleanup
    activate(:white)

    expect(p1.mana_pool[:white]).to eq(1)
  end
end
