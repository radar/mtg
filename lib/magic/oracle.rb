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
      card.slice("name", "mana_cost", "type_line", "oracle_text", "colors", "color_identity", "power", "toughness", "loyalty")
    end

    # Every card whose Scryfall set code is +code+ (e.g. "ecl"), as raw Oracle hashes
    # including card_faces. The oracle data holds one printing per card, so a card
    # reprinted in the set may report its other set.
    def cards_in_set(code)
      @oracle_data.select { |card| card["set"] == code.downcase }
    end

    def search_cards(fragment)
      @oracle_data
        .select { |card| card["name"].downcase.include?(fragment.downcase) }
        .map { |card| card["name"] }
        .uniq
    end
  end
end
