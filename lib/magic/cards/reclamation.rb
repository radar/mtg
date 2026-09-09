module Magic
  module Cards
    Reclamation = Enchantment("Reclamation") do
      cost generic: 2, green: 1, white: 1
    end

    class Reclamation < Enchantment
    end
  end
end