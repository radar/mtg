require 'json'

module Magic
  class Oracle
    class CardNotFound < StandardError; end
    def initialize
      @path = File.expand_path("../../data", __dir__)
      @oracle_data = File.readlines(Dir["#{@path}/*.jsonl"].first).map(&JSON.method(:parse))
    end

    def find_card(name)
      card = @oracle_data.find { |card| card["name"].casecmp(name).zero? }
      raise CardNotFound if card.nil?

      # keep only relevant keys
      card.slice("name", "mana_cost", "type_line", "oracle_text", "colors", "color_identity")
    end
  end
end
