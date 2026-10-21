module Magic
  module Cards
    KamiOfJealousThirst = Creature("Kami of Jealous Thirst") do
      cost generic: 2, black: 1
      creature_type "Spirit"
      power 1
      toughness 3
      keywords :deathtouch
    end

    class KamiOfJealousThirst < Creature
      # "{4}{B}: Each opponent loses 2 life and you gain 2 life. This ability costs {4}{B} less to activate if you've
      # drawn three or more cards this turn. Activate only once each turn."
      class DrainAbility < Magic::ActivatedAbility
        once_each_turn

        def costs
          [Costs::Mana.new(generic: 4, black: 1).adjusted_by({ generic: -4, black: -1 }, -> { drawn_three_or_more? })]
        end

        def drawn_three_or_more?
          game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == controller } >= 3
        end

        def resolve!
          game.opponents(controller).each { lose_life(_1, 2) }
          gain_life 2
        end
      end

      def activated_abilities = [DrainAbility]
    end
  end
end
