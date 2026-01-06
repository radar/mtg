# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Magic::Choice::Surveil do
  include_context "two player game"

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
      Card("Island"),
      Card("Mountain"),
      Card("Plains"),
    ]
  end

  it "can put a card in the graveyard" do
    top_card = p1.library.first
    
    choice = Magic::Choice::Surveil.new(actor: Card("Opt"), amount: 1)
    choice.resolve!(graveyard: [top_card])
    
    expect(p1.graveyard.map(&:name)).to include("Island")
    expect(p1.library.first.name).to eq("Mountain")
  end

  it "can keep a card on top" do
    top_card = p1.library.first
    
    choice = Magic::Choice::Surveil.new(actor: Card("Opt"), amount: 1)
    choice.resolve!(top: [top_card])
    
    expect(p1.graveyard.map(&:name)).not_to include("Island")
    expect(p1.library.first).to eq(top_card)
    expect(p1.library.first.name).to eq("Island")
  end
end
