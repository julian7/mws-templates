# Things to do in mws-templates

## Switch back to RSpec

It was a nice trip to MiniSpec. It has its points, but it also severely
lacks the concept of naming examples, tag them, and it is more or less
unusable for documenting examples.

It also lacks powerful instrumentation: parameters, ability of running a
spec by specifying a line number, etc.

## Spin up RSpec

Spin is a very good preforking rspec runner. It spins up the rails app,
and runs specs on forked copies. Muck like Spork, but it does this
totally unobtrusively. Sadly it doesn't handle cucumber ATM.

## Switch back to Cucumber

Cukes is a powerful tool after all. You have to cuke it right, however.
There are good resources about it, like 'Cuking it right', or Hashrocket
Book Club's episode on Cucumber.

Steak / Capybara is very powerful too, but they can't communicate with
the business.

## Vlad to Debian packages for deployment

Capistrano and Vlad do a good job if you have enough time to have your
assets compiled. Compiled assets should not go under version control, as
bundle cached gems. However, if you don't have them on deployment,
you'll need a couple of things on the server side (development
environment, for example). Use a packaging server instead.

* Servers are maintained through puppet (server)
* Applications are packaged by fpm gem to deb format, published to a ppa repo.
* Deb packages are generated by a packager
  * cheapo: shallow clone locally, doing cleanups and asset packaging
  * reasonable: vagrant box (using target system, also good for rbenv
    debianization)
  * pro: separate packaging server with web interface

Deployment is done in two steps: publishing a package, and re-running
puppet agent on the client.

## Use Twitter Bootstrap for templating

Bootstrap is a cool piece of software. It allows a very simple and
elegant way to bootstrap (sic!) your new web app. 978 is over.