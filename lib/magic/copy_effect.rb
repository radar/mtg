module Magic
  # Resolves a copy of a spell or ability's effect directly, without going
  # through the stack or moving any card between zones -- a copy isn't a real
  # object, it just reproduces the resolution.
  module CopyEffect
    def self.resolve!(receiver, targets: [])
      resolver = receiver.method(:resolve!)
      pool = { target: targets.first, targets: targets }
      args = pool.select do |key, _|
        resolver.parameters.include?([:keyreq, key]) || resolver.parameters.include?([:key, key])
      end
      resolver.call(**args)
    end

    # Resolves `copies` copies of `receiver`, offering the "may choose new
    # targets" choice when it had targets to begin with; otherwise (no
    # targets, or nothing to retarget onto) just resolves the copies directly.
    def self.resolve_with_choice!(actor:, receiver:, targets:, copies: 1)
      copies += actor.game.battlefield.static_abilities.of_type(Abilities::Static::CopyMultiplier).sum(&:additional_copies)

      if targets.any?
        actor.game.add_choice(Magic::Choice::MayCopyTargets.new(actor: actor, receiver: receiver, original_targets: targets, copies: copies))
      else
        copies.times { resolve!(receiver, targets: []) }
      end
    end
  end
end
