require 'spec_helper'

RSpec.describe Magic::Cards::Opt do
  include_context "two player game"

  let(:opt) { described_class.new(game: game) }

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Sol Ring"),
      Card("Forest"),
    ]
  end

  it "scries to the top" do
    top_card = p1.library.first
    p1.add_mana(blue: 1)
    action = cast_action(player: p1, card: opt)
    action.pay_mana(blue: 1)
    game.take_action(action)
    game.tick!
    effect = game.effects.first
    expect(effect).to be_a(Magic::Effects::Scry)
    game.resolve_pending_effect(top: [top_card])

    expect(opt.zone).to be_graveyard
    expect(p1.library.first.name).to eq("Forest")
    expect(p1.hand.map(&:name)).to include("Sol Ring")
  end

  it "scries to the bottom" do
    top_card = p1.library.first
    p1.add_mana(blue: 1)
    action = cast_action(player: p1, card: opt)
    action.pay_mana(blue: 1)
    game.take_action(action)
    game.tick!
    effect = game.effects.first
    expect(effect).to be_a(Magic::Effects::Scry)
    game.resolve_pending_effect(bottom: [top_card])

    expect(opt.zone).to be_graveyard
    expect(p1.library.last).to eq(top_card)

    expect(p1.hand.map(&:name)).not_to include("Sol Ring")
  end
end
