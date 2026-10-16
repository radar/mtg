# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EvolutionWitness do
  include_context "two player game"

  let!(:witness) { ResolvePermanent("Evolution Witness", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }

  def adapt
    p1.add_mana(green: 2)
    p1.activate_ability(ability: witness.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 2/1 Elf Shaman Mutant" do
    expect([witness.power, witness.toughness]).to eq([2, 1])
    expect(witness.type?("Mutant")).to be(true)
  end

  context "{1}{G}: Adapt 2" do
    it "puts two +1/+1 counters on it if it has none and spends the mana" do
      adapt

      expect([witness.power, witness.toughness]).to eq([4, 3])
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect(plus_counters(witness)).to eq(2)
    end

    it "cannot be activated without paying" do
      p1.add_mana(green: 1)

      expect {
        p1.activate_ability(ability: witness.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(plus_counters(witness)).to eq(0)
    end
  end

  context "when +1/+1 counters are put on it" do
    it "returns a permanent card from your graveyard to your hand" do
      adapt

      expect(bears.zone).to eq(p1.hand)
      expect(p1.graveyard.cards).not_to include(bears)
    end

    it "triggers once for the whole group of counters" do
      land = Card("Forest", owner: p1).tap { p1.graveyard.add(_1) }
      adapt

      expect(game.choices.first.choices).to contain_exactly(bears, land)
      game.resolve_choice!(target: land)
      game.settle!
      expect(game.choices).to be_empty
      expect(bears.zone).to be_graveyard
    end

    it "triggers for a single counter placed by another effect" do
      witness.add_counter("+1/+1")
      game.settle!

      expect(bears.zone).to eq(p1.hand)
    end

    it "does not offer nonpermanent cards" do
      spell = Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) }
      land = Card("Forest", owner: p1).tap { p1.graveyard.add(_1) }
      adapt

      expect(game.choices.first.choices).to contain_exactly(bears, land)
      expect(game.choices.first.choices).not_to include(spell)
      expect { game.resolve_choice!(target: spell) }.to raise_error(ArgumentError)
    end

    it "does not offer cards from an opponent's graveyard" do
      theirs = Card("Llanowar Elves", owner: p2).tap { p2.graveyard.add(_1) }
      adapt

      expect(bears.zone).to eq(p1.hand)
      expect(theirs.zone).to be_graveyard
    end

    it "does nothing with no permanent card in your graveyard" do
      p1.graveyard.remove(bears)
      adapt

      expect(game.choices).to be_empty
      expect(plus_counters(witness)).to eq(2)
    end

    it "does not trigger for other kinds of counters" do
      witness.add_counter("-1/-1")
      game.settle!

      expect(bears.zone).to be_graveyard
    end

    it "does not trigger when counters are put on another creature" do
      other = ResolvePermanent("Llanowar Elves", owner: p1)
      other.add_counter("+1/+1")
      game.settle!

      expect(bears.zone).to be_graveyard
    end
  end
end
