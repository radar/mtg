# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Agent do
  subject(:agent) { described_class.new }

  it "documents the contract by raising NotImplementedError for every decision" do
    expect { agent.choose_action(nil, []) }.to raise_error(NotImplementedError)
    expect { agent.choose_targets(nil, []) }.to raise_error(NotImplementedError)
    expect { agent.choose_blockers(nil, []) }.to raise_error(NotImplementedError)
    expect { agent.choose_mana_payment(nil, {}, []) }.to raise_error(NotImplementedError)
    expect { agent.resolve_choice(nil, double("choice")) }.to raise_error(NotImplementedError)
  end
end
