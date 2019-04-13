[![Gem Version](https://badge.fury.io/rb/whatthegem.svg)](http://badge.fury.io/rb/whatthegem)

`whatthegem` is a small utility to answer some questions about Ruby gems you work with, or planning to work with.

It tries to answer—**right in your terminal**—questions like the following:

* Colleague added `gemname` to our `Gemfile`, what is it?
* How outdated is my favorite `gemname` I am using locally, what's changed since than?
* What's that benchmarking `gemname`'s synopsys was, again?
* There is `gemname` advised on the internetz for my problem, is it still maintained? Is it widely used?

There are a lot of ways to answer those questions through Google and various sites, but if you are in a terminal currently, `whatthegem` is fastest, most focused and convenient.

Showcase:

## `whatthegem <gem> info`

![](https://github.com/zverok/whatthegem/blob/master/screenshots/info.png?raw=true)

Just extracts gem's description and version from RubyGems.org and presents it to you alongside your local versions.

## `whatthegem <gem> usage`

![](https://github.com/zverok/whatthegem/blob/master/screenshots/usage.png?raw=true)

Tries to parse gem's GitHub README (or local README, if gem is installed and includes it), and extract Ruby code blocks from there (except trivial, like "Add to your `Gemfile`: `gem 'gemname'`) and prints them. Typically, it is the main/most basic usage examples.

## `whatthegem <gem> changes`

![](https://github.com/zverok/whatthegem/blob/master/screenshots/changes.png?raw=true)

Parses gem's GitHub `Changelog.md`/`NEWS`/`History`, or GitHub releases description, and lists versions and their changes (up to your local version, if it is older than recent one).

## `whatthegem <gem> stats`

![](https://github.com/zverok/whatthegem/blob/master/screenshots/stats.png?raw=true)

Some statistics about gem's maintainance, freshness and popularity (again, from RubyGems.org and GitHub). It doesn't _judges_, just provides helpful quick insights.

> Note that, for example, "not having a new version in last year or two" doesn't necessary means the gem is abandoned, it could be just "complete".

_This functionality is ported from my earlier gem [any_good](https://github.com/zverok/any_good)—after its creation I eventually understood there are several things I'd like to be able to know about the gems, and so whatthegem was born._

## Limitations

* As significant amount of information is taken from GitHub, `whatthegem` is less useful for gems that aren't on GitHub, or doesn't specify their repo URL in gemspec (available via RubyGems.org API); integrating of other source hosting is possible, but currently, in my experience, it seems like \~99% of gems are there;
* Also, GitHub usage/changes extraction for gems that aren't in the root of the repo (like [ActiveRecord](https://github.com/rails/rails/tree/v5.2.3/activerecord)) aren't supported yet;
* As `usage` and `changes` are extracted by heuristics, it doesn't always work well (thoug it **does** in a surprisingily large number of cases);
  * For example, `usage` is typically informative for stand-alone libraries, but hardly so for Rails plugins (with have instructions like "run this generator, add that to config, insert this line in the model" in their README)
  * For other, not all gems have their Changelog findable, or parseable.

## Author

[@zverok](https://zverok.github.io)