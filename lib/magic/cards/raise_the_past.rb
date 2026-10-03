module Magic
  module Cards
    RaiseThePast = Sorcery("Raise the Past") do
      cost generic: 2, white: 2
    end

    class RaiseThePast < Sorcery
      def resolve!
        cards = controller.graveyard.cards.select { _1.type?("Creature") && _1.mana_value <= 2 }
        cards.each { trigger_effect(:return_target_from_graveyard_to_battlefield, target: _1, controller: _1.owner) }
      end
    end
  end
end
