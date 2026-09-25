# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EndBlazeEpiphany do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_end_blaze(x:, target: bears)
    p1.add_mana(red: x + 1)
    p1.cast(card: Card("End Blaze Epiphany"), value_for_x: x) do
      _1.pay_mana(red: 1, x: { red: x })
      _1.targeting(target)
    end
    game.stack.resolve!
  end

  it "deals X damage to the target creature" do
    elves = ResolvePermanent("Wood Elves", owner: p2)
    cast_end_blaze(x: 0, target: elves)
    expect(elves.damage).to eq(0)

    cast_end_blaze(x: 1, target: bears)
    expect(bears.damage).to eq(1)
    expect(game.choices).to be_empty
  end

  context "when the creature dies" do
    let!(:shock) { Card("Shock", owner: p1).tap { p1.library.add(_1) } }
    let!(:top_two) { p1.library.first(2) }

    before { cast_end_blaze(x: 3) }

    it "exiles cards from the top of your library equal to its power, then asks you to choose one" do
      expect(bears.card.zone).to be_graveyard
      expect(top_two.map(&:zone)).to all(be_exile)
      expect(game.choices.last.choices).to eq(top_two)
    end

    it "lets you play the chosen card until the end of your next turn" do
      game.resolve_choice!(target: shock)

      p1.add_mana(red: 1)
      p1.cast(card: shock) do
        _1.pay_mana(red: 1)
        _1.targeting(p2)
      end
      game.stack.resolve!

      expect(p2.life).to eq(18)
      expect(shock.zone).to be_graveyard
    end

    it "lets you play a chosen land" do
      forest = top_two.last
      game.resolve_choice!(target: forest)
      p1.play_land(land: forest)

      expect(p1.permanents.lands.map(&:card)).to include(forest)
    end

    it "doesn't let you play the cards you didn't choose" do
      game.resolve_choice!(target: shock)
      expect { p1.play_land(land: top_two.last) }.to raise_error(Magic::IllegalAction)
    end

    it "doesn't let an opponent play the chosen card" do
      game.resolve_choice!(target: shock)
      expect(game.play_permissions.permits?(shock, p2)).to eq(false)
    end

    it "lasts through your next turn, then ends" do
      game.resolve_choice!(target: shock)

      go_to_main_phase_for!(p2)
      expect(game.play_permissions.permits?(shock, p1)).to eq(true)
      go_to_main_phase_for!(p1)
      expect(game.play_permissions.permits?(shock, p1)).to eq(true)
      go_to_main_phase_for!(p2)
      expect(game.play_permissions.permits?(shock, p1)).to eq(false)
    end
  end
end
