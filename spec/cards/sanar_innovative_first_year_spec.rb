# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanarInnovativeFirstYear do
  include_context "two player game"

  let!(:sanar) { ResolvePermanent("Sanar, Innovative First-Year", owner: p1) }
  let(:filler) { Card("Forest", owner: p1) }
  let(:forest) { Card("Forest", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:shock) { Card("Shock", owner: p1) }
  let(:trooper) { Card("Alaborn Trooper", owner: p1) }

  before do
    # Sanar is blue and red (hybrid); a white creature makes 3 colors among permanents.
    ResolvePermanent("Alaborn Trooper", owner: p1)
    # Top of library: filler (drawn in the draw step), Forest, Grizzly Bears, Shock, Alaborn Trooper
    [trooper, shock, bears, forest, filler].each { |card| p1.library.add(card) }
    go_to_main_phase!
  end

  let(:choice) { game.choices.last }

  it "reveals cards until X nonland cards at the beginning of your first main phase" do
    expect(choice).to be_a(described_class::ExileChoice)
    # X = 3 colors: white, blue, red
    expect(choice.colors).to contain_exactly(:white, :blue, :red)
    expect(choice.revealed).to eq([forest, bears, shock, trooper])
  end

  it "exiles a card of each chosen color and lets you cast them this turn" do
    game.resolve_choice!(exiles: { red: shock, white: trooper })

    expect(shock.zone).to be_a(Magic::Zones::Exile)
    expect(trooper.zone).to be_a(Magic::Zones::Exile)
    expect(bears.zone).to eq(p1.library)
    expect(game.play_permissions.permits?(shock, p1)).to eq(true)
    expect(game.play_permissions.permits?(trooper, p1)).to eq(true)
  end

  it "may exile nothing" do
    game.resolve_choice!(exiles: {})

    expect([forest, bears, shock, trooper].map(&:zone)).to all(eq(p1.library))
  end

  it "rejects a card that is not of the named color" do
    expect { game.resolve_choice!(exiles: { red: bears }) }.to raise_error(ArgumentError)
  end

  it "ends the permission with the turn" do
    game.resolve_choice!(exiles: { red: shock })
    game.next_turn

    expect(game.play_permissions.permits?(shock, p1)).to eq(false)
  end
end
