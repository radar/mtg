# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Magic::Choice::Surveil do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(name: "P1", library: []) }
  
  before do
    p1.instance_variable_set(:@game, game)
    game.add_players(p1, Magic::Player.new(name: "P2"))
    game.start!
    
    # Add cards to library manually in reverse order since add puts them at position 0
    island = Magic::Cards::Island.new(game: game, owner: p1)
    mountain = Magic::Cards::Mountain.new(game: game, owner: p1)
    forest = Magic::Cards::Forest.new(game: game, owner: p1)
    
    p1.library.add(island)
    p1.library.add(mountain)
    p1.library.add(forest)
  end

  it "can put a card in the graveyard" do
    top_card = p1.library.first
    
    choice = Magic::Choice::Surveil.new(actor: Magic::Cards::Opt.new(game: game, owner: p1), amount: 1)
    choice.resolve!(graveyard: [top_card])
    
    expect(p1.graveyard.map(&:name)).to include("Forest")
    expect(p1.library.first.name).to eq("Mountain")
  end

  it "can keep a card on top" do
    top_card = p1.library.first
    
    choice = Magic::Choice::Surveil.new(actor: Magic::Cards::Opt.new(game: game, owner: p1), amount: 1)
    choice.resolve!(top: [top_card])
    
    expect(p1.graveyard.map(&:name)).not_to include("Forest")
    expect(p1.library.first).to eq(top_card)
    expect(p1.library.first.name).to eq("Forest")
  end
end
