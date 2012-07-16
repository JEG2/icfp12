Team
====

OKC Edmonders

Team Members
------------

James Gray
Tim Nordloh
Ed Livengood
Luke DeWitt

About This Solution
-------------------

This is a pretty normal search of all possible moves with moderate pruning.  See `pruned_search()` and `prune?()` in `src/lib/lambda_dash/search.rb` for the main thinking code.  The `prioritize_moves()` method in the same file pushes us down higher scoring lines faster, which isn't perfect but still seems to help more than it hurts.  These three methods are really our brain, so we're getting the results we're getting with less than 50 lines of code.

Something that might surprise you is that this Ruby code uses some functional programming inspired tricks.  Each `Cell` in our `Map` is an immutable object and we replace them with new objects as we make changes.  This allows for a surprisingly quick copy of even large maps, since the copy just points to the same objects for the most part.  Of course, Ruby's no speed demon and we lose plenty of time in other areas.

We named this code Lambda Dash after the Boulder Dash game that we assume was your inspiration for the problem.
