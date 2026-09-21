require "spec_helper"

RSpec.describe Magic::Game, "action legality -- declaring attackers" do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_and_resolve_creature(name, mana)
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(mana)
    p1.cast(card: card) { |a| a.auto_pay_mana }
    game.stack.resolve!
    p1.creatures.by_name(name).first
  end

  def go_to_declare_attackers!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
  end

  def go_to_p1_next_turn_declare_attackers!
    2.times { game.next_turn }
    go_to_main_phase!
    go_to_declare_attackers!
  end

  it "lets an untapped creature its controller has controlled since their turn began attack" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_declare_attackers!

    p1.declare_attacker(attacker: bears, target: p2)

    expect(current_turn.attacking?(bears)).to be(true)
    expect(bears).to be_tapped
  end

  it "lets an attacker be redeclared to change its target without being rejected as tapped" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_declare_attackers!
    p1.declare_attacker(attacker: bears, target: p2)

    expect { p1.declare_attacker(attacker: bears, target: p2) }.not_to raise_error
  end

  context "summoning sickness" do
    it "stops a creature that came under its controller's control this turn from attacking" do
      bears = cast_and_resolve_creature("Grizzly Bears", green: 2)
      go_to_declare_attackers!

      expect { p1.declare_attacker(attacker: bears, target: p2) }
        .to raise_error(Magic::IllegalAction, /summoning sick/)
      expect(current_turn.attacking?(bears)).to be(false)
    end

    it "lets the creature attack on its controller's next turn" do
      bears = cast_and_resolve_creature("Grizzly Bears", green: 2)
      go_to_p1_next_turn_declare_attackers!

      p1.declare_attacker(attacker: bears, target: p2)

      expect(current_turn.attacking?(bears)).to be(true)
    end

    it "does not stop a creature with haste" do
      valet = cast_and_resolve_creature("Devilish Valet", red: 3)
      go_to_declare_attackers!

      p1.declare_attacker(attacker: valet, target: p2)

      expect(current_turn.attacking?(valet)).to be(true)
    end

    it "applies again when control of a creature changes" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.controller = p1
      go_to_declare_attackers!

      expect { p1.declare_attacker(attacker: bears, target: p2) }
        .to raise_error(Magic::IllegalAction, /summoning sick/)
    end
  end

  it "stops a tapped creature from attacking" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!
    go_to_declare_attackers!

    expect { p1.declare_attacker(attacker: bears, target: p2) }
      .to raise_error(Magic::IllegalAction, /is tapped/)
  end

  it "stops a creature with defender from attacking" do
    vine = ResolvePermanent("Portcullis Vine", owner: p1)
    go_to_declare_attackers!

    expect { p1.declare_attacker(attacker: vine, target: p2) }
      .to raise_error(Magic::IllegalAction, /can't attack/)
  end

  it "stops attackers being declared outside the declare attackers step" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { p1.declare_attacker(attacker: bears, target: p2) }
      .to raise_error(Magic::IllegalAction, /declare attackers step/)
  end

  it "stops a player attacking with a creature they do not control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_declare_attackers!

    expect { p1.declare_attacker(attacker: bears, target: p2) }
      .to raise_error(Magic::IllegalAction, /does not control/)
  end

  it "stops the non-active player from attacking" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_declare_attackers!

    expect { p2.declare_attacker(attacker: bears, target: p1) }
      .to raise_error(Magic::IllegalAction, /not .*P2.*turn/)
  end

  it "stops a noncreature permanent from attacking" do
    forest = ResolvePermanent("Forest", owner: p1)
    go_to_declare_attackers!

    expect { p1.declare_attacker(attacker: forest, target: p2) }
      .to raise_error(Magic::IllegalAction, /not a creature/)
  end
end
