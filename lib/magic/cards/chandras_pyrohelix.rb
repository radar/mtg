module Magic
  module Cards
    class ChandrasPyrohelix < Instant
      NAME = "Chandra's Pyrohelix"
      COST = { generic: 1, red: 1 }

      class DivideDamageChoice < Magic::Choice
        def choices
          game.any_target
        end

        def resolve!(distribution:)
          distribution.each do |target, damage|
            deal_damage(damage, to: target)
          end
        end
      end

      def resolve!(**)
        game.choices.add(DivideDamageChoice.new(actor: self))
      end
    end
  end
end
