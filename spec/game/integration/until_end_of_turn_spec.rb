require 'spec_helper'

RSpec.describe Magic::Game, "until end of turn effect" do
  subject(:game) { Magic::Game.new }

  let!(:p1) { game.add_player(library: [Card("Forest")]) }
  let(:dranas_emissary) { Card("Drana's Emissary", controller: p1) }

  before do
    game.battlefield.add(dranas_emissary)
  end

  it "granted keywords are cleared at end of turn" do
    expect(subject).to be_at_step(:untap)
    subject.next_step

    dranas_emissary.grant_keyword(Magic::Cards::Keywords::DEATHTOUCH, until_eot: true)

    until subject.at_step?(:cleanup)
      subject.next_step
    end

    expect(dranas_emissary.deathtouch?).to eq(false)
  end
end
