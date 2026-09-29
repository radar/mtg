require "bundler/setup"
require_relative "../lib/magic"

M = {
  "explore" => /\bexplores?\b/i, "proliferate" => /\bproliferate\b/i, "amass" => /\bamass\b/i,
  "investigate" => /\binvestigate\b/i, "connive" => /\bconnives?\b/i, "incubate" => /\bincubate\b/i,
  "learn" => /\blearn\b/i, "discover" => /\bdiscover \d|\bdiscover X/i, "cascade" => /\bcascade\b/i,
  "convoke" => /\bconvoke\b/i, "delve" => /\bdelve\b/i, "improvise" => /\bimprovise\b/i, "emerge" => /\bemerge\b/i,
  "escape" => /\bescape\b(?!s)/i, "disturb" => /\bdisturb\b/i, "foretell" => /\bforetell\b/i, "jump-start" => /\bjump-start\b/i,
  "aftermath" => /\baftermath\b/i, "bestow" => /\bbestow\b/i, "prototype" => /\bprototype\b/i, "mutate" => /\bmutate\b/i,
  "blitz" => /\bblitz\b/i, "spectacle" => /\bspectacle\b/i, "madness" => /\bmadness\b/i, "evoke" => /\bevoke\b/i,
  "casualty" => /\bcasualty\b/i, "bargain" => /\bbargain\b/i, "spree" => /\bspree\b/i, "offspring" => /\boffspring\b/i,
  "squad" => /\bsquad\b/i, "impending" => /\bimpending\b/i, "riot" => /\briot\b/i, "training" => /\btraining\b/i,
  "mentor" => /\bmentor\b/i, "afterlife" => /\bafterlife\b/i, "undying" => /\bundying\b/i, "persist" => /\bpersist\b/i,
  "exalted" => /\bexalted\b/i, "backup" => /\bbackup\b/i, "crew" => /\bcrew \d/i, "reconfigure" => /\breconfigure\b/i,
  "boast" => /\bboast\b/i, "saddle" => /\bsaddle\b/i, "valiant" => /\bvaliant\b/i, "morph/disguise/manifest" => /\b(morph|disguise|manifest|cloak)\b/i,
  "daybound" => /\bdaybound\b/i, "companion" => /\bcompanion\b/i, "class" => /— Class|Level up|\bclass\b.*level/i,
  "room" => /\bRoom\b/i, "case/solve" => /\bsolved?\b/i, "plot" => /\bplot\b/i, "monarch" => /\bmonarch\b/i, "initiative" => /\binitiative\b/i,
  "dungeon" => /\bventure into\b/i, "energy" => /\{E\}/, "collect evidence" => /collect evidence/i, "suspect" => /\bsuspected?\b/i,
  "forage" => /\bforage\b/i, "endure" => /\bendures?\b/i, "storm" => /\bstorm\b/i, "rebound" => /\brebound\b/i,
  "populate" => /\bpopulate\b/i, "adapt" => /\badapt\b/i, "exhaust" => /\bexhaust\b/i, "station" => /\bstation\b/i,
  "warp" => /\bwarp\b/i, "mobilize" => /\bmobilize\b/i, "behold" => /\bbehold\b/i, "bending" => /\b(air|earth|water|fire)bend/i,
  "adventure" => /Adventure/, "planeswalker" => nil, "battle" => nil, "instead(spell)" => /\binstead\b/,
  "X spell" => /\{X\}/, "additional cost" => /As an additional cost to cast/i, "kicker" => /\bkicker\b/i,
  "multikicker" => /\bmultikicker\b/i, "landcycling" => /\b(land|plains|island|swamp|mountain|forest|basic land)cycling\b/i,
  "ward-nonmana" => /Ward—/, "toxic" => /\btoxic\b/i, "double faced" => nil, "specialize" => /\bspecialize\b/i, "conspire" => /\bconspire\b/i
}
cutoff = "2016-09-01"
cards = Magic::Oracle.new.all_cards.reject { _1["layout"].to_s.match?(/token|emblem|art_series|vanguard|scheme|planar/) }
win = cards.select { _1["released_at"] >= cutoff && _1["legalities"]&.dig("vintage") != "not_legal" }
impl = Dir["lib/magic/cards/*.rb"].map { File.basename(_1, ".rb") }
slug = ->(c) { c["name"].downcase.gsub(/[^a-z ]/, "").split.join("_") }
text = ->(c) { (c["card_faces"] ? c["card_faces"].map { _1["oracle_text"] } : [c["oracle_text"]]).join("\n") }
rows = M.map do |k, re|
  m = case k
      when "planeswalker" then win.select { _1["type_line"].include?("Planeswalker") }
      when "battle" then win.select { _1["type_line"].include?("Battle") }
      when "double faced" then win.select { _1["layout"] =~ /transform|modal_dfc|meld/ }
      else win.select { text.(_1) =~ re }
      end
  [k, m.size, m.count { !impl.include?(slug.(_1)) }]
end
puts "window cards: #{win.size}"
rows.sort_by { -_1[2] }.each { |k, n, u| puts format("%-26s total %4d  unimplemented %4d", k, n, u) }
