require "spec_helper"

RSpec.describe Magic::Game, "action legality -- declaring blockers" do
  include_context "two player game"

  before { go_to_main_phase! }

  def declare_bears_attacking(target: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: target)
    current_turn.attackers_declared!
    bears
  end

  it "lets an untapped creature the defending player controls block a declared attacker" do
    attacker = declare_bears_attacking
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)

    p2.declare_blocker(blocker: blocker, attacker: attacker)

    expect(current_turn.blocking?(blocker)).to be(true)
  end

  it "cannot be declared outside the declare blockers step" do
    attacker = declare_bears_attacking
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.combat_damage!

    expect { p2.declare_blocker(blocker: blocker, attacker: attacker) }
      .to raise_error(Magic::IllegalAction, /not the declare blockers step/)
  end

  it "cannot be declared by a creature the defending player doesn't control" do
    attacker = declare_bears_attacking
    not_defenders = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { p1.declare_blocker(blocker: not_defenders, attacker: attacker) }
      .to raise_error(Magic::IllegalAction, /isn't controlled by the defending player/)
  end

  it "cannot be declared by a player who doesn't control that blocker at all" do
    attacker = declare_bears_attacking
    other_bears = ResolvePermanent("Grizzly Bears", owner: p1)

    expect { p2.declare_blocker(blocker: other_bears, attacker: attacker) }
      .to raise_error(Magic::IllegalAction, /P2.*does not control/)
  end

  it "cannot be a tapped creature" do
    attacker = declare_bears_attacking
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    blocker.tap!

    expect { p2.declare_blocker(blocker: blocker, attacker: attacker) }
      .to raise_error(Magic::IllegalAction, /is tapped/)
  end

  it "cannot block something that isn't attacking" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.attackers_declared!
    not_attacking = ResolvePermanent("Grizzly Bears", owner: p1)
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)

    expect { p2.declare_blocker(blocker: blocker, attacker: not_attacking) }
      .to raise_error(Magic::IllegalAction, /isn't attacking/)
  end
end
