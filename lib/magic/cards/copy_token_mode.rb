module Magic
  module Cards
    # "Create a token that's a copy of target <creature type> you control." Subclass and
    # call `creature_type "Kithkin"`.
    class CopyTokenMode < Mode
      class << self
        def creature_type(type = nil)
          @creature_type = type if type
          @creature_type
        end
      end

      def target_choices
        battlefield.creatures.controlled_by(controller).select { _1.type?(self.class.creature_type) }
      end

      def resolve!(target:)
        Permanent.resolve(
          game: game,
          owner: controller,
          card: target.copiable_card,
          token: true,
          copy: true,
          cast: false,
        )
      end
    end
  end
end
