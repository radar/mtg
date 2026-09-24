require "spec_helper"

RSpec.describe Magic::Cards::CunningRhetoric do
  include_context "two player game"

  # Seven cards of opening hand, then the card p2 draws for their turn, then Grizzly Bears.
  def p2_library
    [*Array.new(8) { Card("Mountain") }, Card("Grizzly Bears", owner: p2), *Array.new(10) { Card("Mountain") }]
  end

  let!(:rhetoric) { ResolvePermanent("Cunning Rhetoric", owner: p1) }
  let!(:attacker) { ResolvePermanent("Wood Elves", owner: p2) }

  def attack(player, creature, target)
    current_turn.declare_attackers!
    player.declare_attacker(attacker: creature, target: target)
    current_turn.attackers_declared!
    game.settle!
  end

  context "when an opponent attacks you" do
    before do
      go_to_main_phase_for!(p2)
      skip_to_combat!
    end

    it "exiles the top card of that player's library" do
      expect { attack(p2, attacker, p1) }.to change { p2.library.count }.by(-1)

      expect(rhetoric.exiled_cards.map(&:name)).to eq(["Grizzly Bears"])
      expect(game.exile.map(&:name)).to include("Grizzly Bears")
    end

    it "lets you cast that card, spending mana as though it were any color" do
      attack(p2, attacker, p1)
      bears = rhetoric.exiled_cards.first
      go_to_main_phase_for!(p1)

      p1.add_mana(black: 2)
      p1.cast(card: bears) { _1.pay_mana(generic: { black: 1 }, black: 1) }
      game.stack.resolve!

      permanent = game.battlefield.creatures.by_name("Grizzly Bears").last
      expect(permanent.controller).to eq(p1)
      expect(permanent.owner).to eq(p2)
    end
  end

  context "when an opponent attacks a planeswalker you control" do
    let!(:teferi) { ResolvePermanent("Teferi, Master Of Time", owner: p1) }

    before do
      go_to_main_phase_for!(p2)
      skip_to_combat!
    end

    it "exiles the top card of their library" do
      expect { attack(p2, attacker, teferi) }.to change { p2.library.count }.by(-1)
    end
  end

  context "when you attack" do
    let!(:mine) { ResolvePermanent("Wood Elves", owner: p1) }

    before { skip_to_combat! }

    it "doesn't exile anything" do
      expect { attack(p1, mine, p2) }.not_to(change { p2.library.count })
      expect(rhetoric.exiled_cards).to be_empty
    end
  end

  context "with a card in exile that Cunning Rhetoric didn't exile" do
    let(:stranger) { Card("Grizzly Bears", owner: p2) }

    before do
      go_to_main_phase!
      game.exile.add(stranger)
    end

    it "doesn't let you cast it" do
      p1.add_mana(green: 2)
      expect { p1.cast(card: stranger) { _1.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(Magic::IllegalAction)
    end

    it "doesn't let you spend mana as though it were any color for it" do
      p1.add_mana(black: 2)
      expect { p1.cast(card: stranger) { _1.pay_mana(generic: { black: 1 }, black: 1) } }.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
