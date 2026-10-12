module Magic
  module Cards
    OsteomancerAdept = Creature("Osteomancer Adept") do
      cost generic: 1, black: 1
      creature_type("Squirrel Warlock")
      keywords :deathtouch
      power 2
      toughness 2
    end

    class OsteomancerAdept < Creature
      # {T}: Until end of turn, you may cast creature spells from your graveyard by foraging in addition to paying
      # their other costs. If you cast a spell this way, that creature enters with a finality counter on it.
      class GraveyardCasting < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          source.state[:graveyard_casting_turn] = game.current_turn.number
          controller.graveyard.creatures.each do |card|
            game.play_permissions.grant_until_end_of_turn(card: card, player: controller, from_graveyard: true)
            card.enter_with_counters_this_turn!({ "finality" => 1 })
          end
        end
      end

      def activated_abilities = [GraveyardCasting]

      # The forage that goes with each graveyard cast this turn.
      class ForageToCast < StaticAbility
        attr_reader :source

        def additional_cost_for(card, player)
          return unless player == source.controller && card.creature? && card.zone&.graveyard?
          return unless source.state[:graveyard_casting_turn] == source.game.current_turn.number

          Costs::Forage.new(card)
        end
      end

      def static_abilities = [ForageToCast]
    end
  end
end
