require "spec_helper"

RSpec.describe Magic::Game, "action legality -- activating loyalty abilities" do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:basri) { ResolvePermanent("Basri Ket", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:plus_one) { basri.loyalty_abilities[0] }
  let(:minus_six) { basri.loyalty_abilities[2] }

  # Basri's +1 needs a target creature to resolve.
  def activate_and_resolve(ability)
    p1.activate_loyalty_ability(ability: ability) { _1.targeting(bears) }
    game.stack.resolve!
  end

  it "can be activated in the active player's main phase with an empty stack" do
    activate_and_resolve(plus_one)

    expect(basri.loyalty).to eq(4)
  end

  it "cannot be activated outside a main phase" do
    current_turn.beginning_of_combat!

    expect { p1.activate_loyalty_ability(ability: plus_one) }
      .to raise_error(Magic::IllegalAction, /not a main phase/)
    expect(basri.loyalty).to eq(3)
  end

  it "cannot be activated on the opponent's turn" do
    go_to_main_phase_for!(p2)

    expect { p1.activate_loyalty_ability(ability: plus_one) }
      .to raise_error(Magic::IllegalAction, /not .*P1.*turn/)
  end

  it "cannot be activated while the stack is not empty" do
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }

    expect { p1.activate_loyalty_ability(ability: plus_one) }
      .to raise_error(Magic::IllegalAction, /stack is not empty/)
  end

  it "cannot be activated a second time in the same turn" do
    activate_and_resolve(plus_one)

    expect { p1.activate_loyalty_ability(ability: plus_one) { _1.targeting(bears) } }
      .to raise_error(Magic::IllegalAction, /already activated a loyalty ability this turn/)
    expect(basri.loyalty).to eq(4)
  end

  it "can be activated again on the controller's next turn" do
    activate_and_resolve(plus_one)
    2.times { game.next_turn }
    go_to_main_phase!

    activate_and_resolve(plus_one)

    expect(basri.loyalty).to eq(5)
  end

  it "lets a different planeswalker activate in the same turn" do
    ob_nixilis = ResolvePermanent("Ob Nixilis Reignited", owner: p1)
    activate_and_resolve(plus_one)

    p1.activate_loyalty_ability(ability: ob_nixilis.loyalty_abilities[0])
    game.stack.resolve!

    expect(ob_nixilis.loyalty).to eq(6)
  end

  it "cannot be activated when the planeswalker does not have enough loyalty to pay the cost" do
    expect { p1.activate_loyalty_ability(ability: minus_six) }
      .to raise_error(Magic::IllegalAction, /does not have enough loyalty/)
    expect(basri.loyalty).to eq(3)
  end

  it "cannot be activated by a player who does not control the planeswalker" do
    go_to_main_phase_for!(p2)

    expect { p2.activate_loyalty_ability(ability: plus_one) }
      .to raise_error(Magic::IllegalAction, /does not control/)
  end

  it "can be activated at instant speed when the ability says so" do
    teferi = ResolvePermanent("Teferi, Master Of Time", owner: p1)
    go_to_main_phase_for!(p2)

    p1.activate_loyalty_ability(ability: teferi.loyalty_abilities.first)

    expect(teferi.loyalty).to eq(4)
  end
end
