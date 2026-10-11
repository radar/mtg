module Magic
  module Cards
    SelfReflection = Sorcery("Self-Reflection") do
      cost generic: 4, blue: 2
      flashback Costs::Mana.new(generic: 3, blue: 1)
    end

    class SelfReflection < Sorcery
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        Permanent.token_copy(game: game, owner: controller, card: target.copiable_card)
      end
    end
  end
end
