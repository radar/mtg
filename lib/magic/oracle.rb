require 'json'

module Magic
  class Oracle
    class CardNotFound < StandardError; end
    def initialize(path: File.expand_path("../../data", __dir__))
      @path = path
      # Every data/*.jsonl file is loaded, in filename order. @printings keeps every record, so a card reprinted
      # in several files still shows up in each file's set. @oracle_data has one record per card name, the
      # first file's winning, so a per-set export overrides the one-printing-per-card dump.
      @printings = Dir["#{@path}/*.jsonl"].sort.flat_map { |file| File.readlines(file).map(&JSON.method(:parse)) }
      @oracle_data = @printings.uniq { |card| card["name"] }
    end

    def find_card(name)
      matches = @oracle_data.select { |card| card["name"].casecmp(name).zero? }
      # A token can share its name with a card (Intrepid Rabbit): the card wins.
      card = matches.find { |match| match["layout"] != "token" } || matches.first
      raise CardNotFound if card.nil?

      # keep only relevant keys
      card.slice("name", "mana_cost", "type_line", "oracle_text", "colors", "color_identity", "power", "toughness", "loyalty", "card_faces")
    end

    # Every card whose Scryfall set code is +code+ (e.g. "ecl"), as raw Oracle hashes
    # including card_faces. Looks at every printing in every data file, so a card reprinted in another set's
    # file (or in the one-printing-per-card dump under a different set) is still listed once here.
    def cards_in_set(code)
      @printings.select { |card| card["set"] == code.downcase }.uniq { |card| card["name"] }
    end

    # Every card in the Oracle data, as raw hashes including card_faces.
    def all_cards = @oracle_data

    def search_cards(fragment)
      @oracle_data
        .select { |card| card["name"].downcase.include?(fragment.downcase) }
        .map { |card| card["name"] }
        .uniq
    end
  end
end
