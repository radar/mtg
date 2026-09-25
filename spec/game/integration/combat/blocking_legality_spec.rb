# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "combat -- blocking legality" do
  include_context "two player game"

  let(:keywords) { Magic::Cards::Keywords }
  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Wood Elves", owner: p2) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.attackers_declared!
  end

  def block!(creature = blocker)
    current_turn.declare_blocker(creature, attacker: attacker)
  end

  it "allows an ordinary block" do
    attack!
    expect { block! }.not_to raise_error
  end

  it "rejects a tapped blocker" do
    blocker.tap!
    attack!
    expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /tapped/)
  end

  it "rejects a creature the defending player doesn't control" do
    attack!
    ally = ResolvePermanent("Wood Elves", owner: p1)
    expect { block!(ally) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /defending player/)
  end

  it "rejects a creature that is already blocking another attacker" do
    other_attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p2)
    current_turn.declare_attacker(other_attacker, target: p2)
    current_turn.attackers_declared!

    current_turn.declare_blocker(blocker, attacker: attacker)
    expect { current_turn.declare_blocker(blocker, attacker: other_attacker) }
      .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /already blocking/)
  end

  describe "flying and reach" do
    before { attacker.grant_keyword(keywords::FLYING) }

    it "can't be blocked by a creature without flying or reach" do
      attack!
      expect(current_turn.can_block?(attacker: attacker, blocker: blocker)).to eq(false)
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /flying/)
    end

    it "can be blocked by a creature with flying" do
      blocker.grant_keyword(keywords::FLYING)
      attack!
      expect { block! }.not_to raise_error
    end

    it "can be blocked by a creature with reach" do
      blocker.grant_keyword(keywords::REACH)
      attack!
      expect { block! }.not_to raise_error
    end
  end

  describe "menace" do
    let!(:second_blocker) { ResolvePermanent("Wood Elves", owner: p2) }

    before { attacker.grant_keyword(keywords::MENACE) }

    it "can't be blocked except by two or more creatures" do
      attack!
      block!

      expect { current_turn.combat_damage! }
        .to raise_error(Magic::Game::CombatPhase::IllegalBlock, /menace/)
    end

    it "can be blocked by two creatures" do
      attack!
      block!
      block!(second_blocker)

      expect { current_turn.combat_damage! }.not_to raise_error
    end

    it "can go unblocked" do
      attack!
      expect { current_turn.combat_damage! }.not_to raise_error
    end
  end

  describe "can't be blocked" do
    it "can't be blocked by any creature" do
      attacker.grant_keyword(keywords::CANT_BE_BLOCKED)
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /can't be blocked/)
    end
  end

  describe "fear" do
    before { attacker.grant_keyword(keywords::FEAR) }

    it "can't be blocked by a nonblack, nonartifact creature" do
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /fear/)
    end

    it "can be blocked by a black creature" do
      black_blocker = ResolvePermanent("Flensermite", owner: p2)
      attack!
      expect { block!(black_blocker) }.not_to raise_error
    end

    it "can be blocked by an artifact creature" do
      artifact_blocker = ResolvePermanent("Forgotten Sentinel", owner: p2)
      artifact_blocker.untap!
      attack!
      expect { block!(artifact_blocker) }.not_to raise_error
    end
  end

  describe "intimidate" do
    before { attacker.grant_keyword(keywords::INTIMIDATE) }

    it "can't be blocked by a creature that shares no color and isn't an artifact" do
      black_blocker = ResolvePermanent("Flensermite", owner: p2)
      attack!
      expect { block!(black_blocker) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /intimidate/)
    end

    it "can be blocked by a creature that shares a color" do
      attack!
      expect { block! }.not_to raise_error
    end

    it "can be blocked by an artifact creature" do
      artifact_blocker = ResolvePermanent("Forgotten Sentinel", owner: p2)
      artifact_blocker.untap!
      attack!
      expect { block!(artifact_blocker) }.not_to raise_error
    end
  end

  describe "shadow" do
    it "can't be blocked by a creature without shadow" do
      attacker.grant_keyword(keywords::SHADOW)
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /shadow/)
    end

    it "can be blocked by a creature with shadow" do
      attacker.grant_keyword(keywords::SHADOW)
      blocker.grant_keyword(keywords::SHADOW)
      attack!
      expect { block! }.not_to raise_error
    end

    it "can't be blocked by a shadow creature when it lacks shadow itself" do
      blocker.grant_keyword(keywords::SHADOW)
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /shadow/)
    end
  end

  describe "horsemanship" do
    it "can't be blocked by a creature without horsemanship" do
      attacker.grant_keyword(keywords::HORSEMANSHIP)
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /horsemanship/)
    end
  end

  describe "skulk" do
    before { attacker.grant_keyword(keywords::SKULK) }

    it "can't be blocked by a creature with greater power" do
      big_blocker = ResolvePermanent("Vastwood Gorger", owner: p2)
      attack!
      expect { block!(big_blocker) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /skulk/)
    end

    it "can be blocked by a creature with equal or lesser power" do
      attack!
      expect { block! }.not_to raise_error
    end
  end

  describe "landwalk" do
    it "can't be blocked while the defending player controls a land of that type" do
      ResolvePermanent("Forest", owner: p2)
      attacker.grant_keyword(keywords::Landwalk.new("Forest"))
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /forestwalk/)
    end

    it "can be blocked when the defending player has no such land" do
      ResolvePermanent("Mountain", owner: p2)
      attacker.grant_keyword(keywords::Landwalk.new("Forest"))
      attack!
      expect { block! }.not_to raise_error
    end
  end

  describe "can't block" do
    it "rejects a creature that can't block this attacker" do
      allow(blocker).to receive(:can_block?).with(attacker).and_return(false)
      attack!
      expect { block! }.to raise_error(Magic::Game::CombatPhase::IllegalBlock, /can't block/)
    end
  end
end
