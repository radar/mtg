# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MaralenFaeAscendant do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:top_two) { p2.library.first(2) }

  it "is a legendary 4/5 flying Elf Faerie Noble" do
    maralen = ResolvePermanent("Maralen, Fae Ascendant", owner: p1)
    expect(maralen).to be_legendary
    expect([maralen.power, maralen.toughness]).to eq([4, 5])
    expect(maralen).to be_flying
    expect(maralen).to be_type("Faerie")
  end

  it "exiles the top two cards of the opponent's library when it enters" do
    cards = top_two
    ResolvePermanent("Maralen, Fae Ascendant", owner: p1)
    expect(cards.map(&:zone)).to all(be_exile)
  end

  context "with Maralen on the battlefield" do
    let!(:maralen) { ResolvePermanent("Maralen, Fae Ascendant", owner: p1) }

    it "exiles two more when another Elf you control enters" do
      cards = top_two
      ResolvePermanent("Wood Elves", owner: p1)
      expect(cards.map(&:zone)).to all(be_exile)
    end

    it "doesn't trigger for a non-Elf, non-Faerie creature, or an opponent's Elf" do
      cards = top_two
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Wood Elves", owner: p2)
      expect(cards.map(&:zone)).to all(be_library)
    end

    context "with cheap spells exiled this turn" do
      let(:bears) { Card("Grizzly Bears", owner: p2) }
      let(:shock) { Card("Shock", owner: p2) }

      before do
        [bears, shock].each { p2.library.add(_1) }
        ResolvePermanent("Wood Elves", owner: p1) # exiles Shock and the bears; two Elves now
      end

      it "lets you cast one of them without paying its mana cost" do
        expect(bears.zone).to be_exile
        p1.cast(card: bears)
        game.stack.resolve!

        permanent = p1.creatures.find { _1.card == bears }
        expect(permanent.controller).to eq(p1)
        expect(permanent.owner).to eq(p2)
      end

      it "only once each turn" do
        p1.cast(card: shock) { _1.targeting(p2) }
        game.stack.resolve!
        expect(p2.life).to eq(18)
        expect(shock.zone).to eq(p2.graveyard)

        expect { p1.cast(card: bears) }.to raise_error(Magic::IllegalAction)
      end

      it "not on a later turn" do
        current_turn.end!
        current_turn.cleanup!
        go_to_main_phase_for!(p2)
        go_to_main_phase_for!(p1)
        expect { p1.cast(card: bears) }.to raise_error(Magic::IllegalAction)
      end
    end

    it "not a spell with mana value greater than the number of Elves and Faeries you control" do
      taster = Card("Taster Of Wares", owner: p2) # mana value 3; Maralen is the only Elf or Faerie
      p2.library.add(taster)
      # Exile the top two again, as Maralen's trigger does.
      p2.library.first(2).each { maralen.exile_with_this!(_1) }

      expect(taster.zone).to be_exile
      expect { p1.cast(card: taster) }.to raise_error(Magic::IllegalAction)
    end
  end
end
