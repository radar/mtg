# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Renew do
  it "parses the mana cost and effects after the Renew ability word is dropped" do
    rule = described_class.parse("{1}{G}, Exile ~ from your graveyard: Put a +1/+1 counter and a trample counter on target creature. Activate only as a sorcery.")
    expect(rule.cost).to eq("{1}{G}")
    expect(rule.hook).to eq(:graveyard_abilities)
  end

  it "renders a graveyard ability class that exiles the card as a cost" do
    source = described_class.parse("{B}, Exile ~ from your graveyard: Put a +1/+1 counter on target creature. Activate only as a sorcery.").class_source("GraveyardAbility")
    expect(source).to include('costs "{B}, Exile {this}"', "activate_from_graveyard_as_sorcery", "class GraveyardAbility < Magic::ActivatedAbility")
  end

  it "ignores other activated abilities and unsupported effects" do
    expect(described_class.parse("{1}{G}, {T}: Draw a card.")).to be_nil
    expect(described_class.parse("{1}{G}, Exile ~ from your graveyard: Put a +1/+1 counter on target creature.")).to be_nil
    expect(described_class.parse("{1}{G}, Exile ~ from your graveyard: Frobnicate. Activate only as a sorcery.")).to be_nil
  end
end
