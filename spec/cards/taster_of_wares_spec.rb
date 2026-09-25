# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TasterOfWares do
  include_context "two player game"

  let!(:shock) { Card("Shock", owner: p2).tap { p2.hand.add(_1) } }
  let!(:bears) { Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) } }

  before { go_to_main_phase! }

  def reveal(*cards) = game.resolve_choice!(cards:)

  it "is a 3/2 Goblin Warlock" do
    taster = ResolvePermanent("Taster Of Wares", owner: p1)
    expect([taster.power, taster.toughness]).to eq([3, 2])
    expect(taster).to be_type("Goblin")
  end

  context "with Taster of Wares the only Goblin" do
    let!(:taster) { ResolvePermanent("Taster Of Wares", owner: p1) }

    it "has the opponent reveal one card, which you exile" do
      choice = game.choices.last
      expect(choice).to be_a(described_class::RevealChoice)
      expect(choice.player).to eq(p2)
      expect(choice.amount).to eq(1)
      expect { choice.resolve!(cards: [shock, bears]) }.to raise_error(ArgumentError)

      reveal(shock)
      expect(shock).to be_revealed
      game.resolve_choice!(target: shock)
      expect(shock.zone).to be_exile
    end

    context "when an instant is exiled" do
      before do
        reveal(shock)
        game.resolve_choice!(target: shock)
      end

      it "lets you cast it, spending mana of any type" do
        p1.add_mana(black: 1)
        p1.cast(card: shock) do
          _1.pay_mana(black: 1)
          _1.targeting(p2)
        end
        game.stack.resolve!

        expect(p2.life).to eq(18)
        expect(shock.zone).to eq(p2.graveyard)
      end

      it "doesn't let the opponent cast it" do
        p2.add_mana(red: 1)
        expect { p2.cast(card: shock) { _1.pay_mana(red: 1).targeting(p1) } }.to raise_error(Magic::IllegalAction)
      end

      it "stops letting you cast it once Taster of Wares leaves the battlefield" do
        taster.destroy!
        p1.add_mana(red: 1)
        expect { p1.cast(card: shock) { _1.pay_mana(red: 1).targeting(p2) } }.to raise_error(Magic::IllegalAction)
      end
    end

    it "doesn't let you cast an exiled creature card" do
      reveal(bears)
      game.resolve_choice!(target: bears)
      p1.add_mana(green: 2)
      expect { p1.cast(card: bears) { _1.pay_mana(green: 1, generic: { green: 1 }) } }.to raise_error(Magic::IllegalAction)
    end
  end

  it "reveals as many cards as Goblins you control" do
    ResolvePermanent("Elder Auntie", owner: p1)
    ResolvePermanent("Taster Of Wares", owner: p1)

    expect(game.choices.last.amount).to eq(3)
  end

  it "reveals the whole hand, with no choice, when it has X cards or fewer" do
    p2.hand.cards.dup.each { _1.move_to_graveyard! unless _1 == shock }
    ResolvePermanent("Taster Of Wares", owner: p1)

    choice = game.choices.last
    expect(choice).to be_a(described_class::ExileChoice)
    expect(choice.choices).to eq([shock])
  end
end
