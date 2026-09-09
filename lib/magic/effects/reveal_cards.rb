module Magic
  module Effects
    class RevealCards < TargetedEffect
      def inspect
        "#<Effects::RevealCards player=#{source.controller.name} cards=#{target.map(&:name).join(", ")}>"
      end

      def resolve!
        source.controller.reveal(target)
      end
    end
  end
end
