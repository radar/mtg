# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrimServant do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:target) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } } # mana value 2
  let!(:big) { Card("Rottenmouth Viper", owner: p1).tap { p1.library.add(_1) } } # mana value 6

  it "is a 3/2 with menace" do
    servant = ResolvePermanent("Grim Servant", owner: p1)
    game.settle!
    expect(servant.power).to eq(3)
    expect(servant.keywords).to include(Magic::Cards::Keywords::MENACE)
  end

  it "searches for a card with mana value up to your devotion to black and loses 3 life" do
    ResolvePermanent("Sneaky Snacker", owner: p1) # devotion to black 1
    ResolvePermanent("Grim Servant", owner: p1) # devotion to black 2
    game.settle!

    choice = game.choices.first
    expect(choice.choices).to include(target)
    expect(choice.choices).not_to include(big)

    life = p1.life
    game.resolve_choice!(targets: [target])
    expect(p1.hand.cards).to include(target)
    expect(p1.life).to eq(life - 3)
  end

  it "only offers cards within devotion" do
    ResolvePermanent("Grim Servant", owner: p1)
    game.settle!

    expect(game.choices.first.choices).not_to include(target)
  end
end
