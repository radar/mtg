module Magic
  module Cards
    MistralSinger = Creature("Mistral Singer") do
      creature_type "Siren"
      cost generic: 2, blue: 1
      power 2
      toughness 2
      keywords :flying, :prowess
    end
  end
end
