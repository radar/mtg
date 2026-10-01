# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SongcrafterMage do
  include_context "two player game"
  before { go_to_main_phase! }

  # An instant with no harmonize of its own.
  let(:opt) { Card("Opt", owner: p1) }

  it "is a 3/2 Human Bard with flash" do
    permanent = ResolvePermanent("Songcrafter Mage", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([3, 2])
    expect(permanent).to be_flash
  end

  context "when it enters" do
    # The graveyard's only instant or sorcery is the target, so it is chosen automatically.
    before do
      p1.graveyard.add(opt)
      ResolvePermanent("Songcrafter Mage", owner: p1)
    end

    it "lets the chosen instant or sorcery be cast from the graveyard for its mana cost, then exiled" do
      p1.add_mana(blue: 1)
      p1.cast(card: opt, harmonize: true) { |a| a.pay_mana(blue: 1) }
      game.stack.resolve!

      expect(opt.zone).to be_exile
    end

    it "can be paid for with a tapped creature, like any harmonize cost" do
      bear = ResolvePermanent("Grizzly Bears", owner: p1)
      action = Magic::Actions::Cast.new(game: game, player: p1, card: opt, harmonize: true)
      action.harmonize_tap(bear)

      expect(action.mana_cost.cost).to eq(blue: 1)
      expect(bear).to be_tapped
    end

    it "only lasts until end of turn" do
      expect(opt.harmonize_cost).not_to be_nil

      current_turn.end!
      current_turn.cleanup!
      game.next_turn

      expect(opt.harmonize_cost).to be_nil
    end
  end

  it "doesn't let a card without harmonize be cast from the graveyard" do
    p1.graveyard.add(opt)
    p1.add_mana(blue: 1)

    expect { p1.cast(card: opt, harmonize: true) { |a| a.pay_mana(blue: 1) } }.to raise_error(Magic::IllegalAction)
  end
end
