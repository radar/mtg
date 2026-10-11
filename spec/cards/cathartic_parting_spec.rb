# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CatharticParting do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Cathartic Parting", owner: p1).tap { p1.hand.add(_1) } }
  let!(:sanctum) { ResolvePermanent("Sanctum Of Calm Waters", owner: p2) }
  let!(:graveyard) { 5.times.map { Card("Forest", owner: p1).tap { p1.graveyard.add(_1) } } }

  def cast(*targets)
    p1.add_mana(green: 2)
    p1.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "has its owner shuffle target artifact or enchantment an opponent controls into their library" do
    library_size = p2.library.count
    cast(sanctum)

    expect(sanctum.zone).to be_nil
    expect(p2.library.count).to eq(library_size + 1)
    expect(sanctum.card.zone).to be_library
  end

  it "shuffles up to four target cards from your graveyard into your library" do
    library_size = p1.library.count
    cast(sanctum, *graveyard.first(4))

    expect(graveyard.first(4).map(&:zone)).to all(be_library)
    expect(graveyard.last.zone).to be_graveyard
    expect(p1.library.count).to eq(library_size + 4)
  end

  it "may shuffle fewer than four, or none" do
    cast(sanctum, graveyard.first)

    expect(graveyard.first.zone).to be_library
    expect(graveyard[1].zone).to be_graveyard
  end

  it "can't target five graveyard cards" do
    expect { cast(sanctum, *graveyard) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target your own permanent or a creature with the first target" do
    mine = ResolvePermanent("Sanctum Of Tranquil Light", owner: p1)

    expect { cast(mine) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    expect { cast(ResolvePermanent("Grizzly Bears", owner: p2)) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target the same graveyard card twice" do
    expect { cast(sanctum, graveyard.first, graveyard.first) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
