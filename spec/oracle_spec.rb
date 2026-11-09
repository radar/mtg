# frozen_string_literal: true

require "spec_helper"
require "json"
require "fileutils"

RSpec.describe Magic::Oracle do
  let(:dir) { File.expand_path("../tmp/oracle_spec", __dir__) }

  def write_jsonl(name, cards)
    File.write(File.join(dir, name), cards.map(&:to_json).join("\n") + "\n")
  end

  before do
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
    write_jsonl("a_set.jsonl", [{ "name" => "Sol Ring", "set" => "mh3", "oracle_text" => "from mh3" }])
    write_jsonl("b_dump.jsonl", [
      { "name" => "Sol Ring", "set" => "ltr", "oracle_text" => "from dump" },
      { "name" => "Lembas", "set" => "ltr", "oracle_text" => "lembas" }
    ])
  end

  after { FileUtils.rm_rf(dir) }

  subject(:oracle) { described_class.new(path: dir) }

  it "uses the first file's record for a card found in several files" do
    expect(oracle.find_card("Sol Ring")["oracle_text"]).to eq("from mh3")
  end

  it "still lists a reprinted card in a later file's set" do
    expect(oracle.cards_in_set("ltr").map { _1["name"] }).to contain_exactly("Sol Ring", "Lembas")
  end

  it "lists a card once per set" do
    expect(oracle.cards_in_set("mh3").map { _1["name"] }).to eq(["Sol Ring"])
  end
end
