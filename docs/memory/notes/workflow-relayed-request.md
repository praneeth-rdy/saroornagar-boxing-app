# tiered-build workers see the latest chat message as "the request" (observed 2026-11-05)

When the owner sends an unrelated message while a `tiered-build` run is in flight (for
example a logo request during the email sign-in build), workers dispatched afterwards treat
that latest message as the user request and return BLOCKED for a package that does not
match it. An "Owner request this serves" line in the package did not help. What works:
dispatch the package directly with the `Agent` tool (`developer`, then `assistant` for
tests and proofs), stating in the prompt that this is the task being asked for now.
Consider making `tiered-build.js` quote the originating request in every prompt.
