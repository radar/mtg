module Magic
  module Cards
    StrixSerenade = Instant("Strix Serenade") do
      cost blue: 1
    end

    class StrixSerenade < Instant
      BirdToken = Token.create "Bird" do
        creature_type "Bird"
        power 2
        toughness 2
        colors :blue
        keywords :flying
      end

      def single_target?
        true
      end

      def target_choices
        game.stack.spells.select { _1.card.type?("Artifact") || _1.card.type?("Creature") || _1.card.type?("Planeswalker") }
      end

      # "Counter target artifact, creature, or planeswalker spell. Its controller creates a 2/2 blue Bird creature token
      # with flying."
      def resolve!(target:)
        spell_controller = target.player
        counter_spell(target)
        create_token(token: BirdToken, controller: spell_controller)
      end
    end
  end
end
