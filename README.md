# Rails3 template used by Magic Workshop Ltd.

## Preparation
    mkdir rails-nursery && cd rails-nursery
    rbenv install 1.9.3-p125
    rbenv local 1.9.3-p125
    gem install bundler --pre
    bundle init
    echo 'gem "rails", "3.2.1" # or whatever' >> Gemfile
    bundle --path=vendor --binstubs

## Usage

    /path/to/rails-nursery/bin/rails new <app name> -T -skip-bundle -m http://github.com/julian7/mws-templates/raw/master/template.rb
    cd <app name>
    rbenv local 1.9.3-p125

## rwm-template generators

rwm-template comes in a gem as well, for more rails generators:

* mws:layout: generates a standard layout we build on.
* mws:vlad: generates necessary files for deployment.
* mws:auth: generates basic authentication / authorization template with proper specs.
* mws:scaffold: our standard crud scaffold (to be exported).

## mws:vlad: How to deploy?

Our deployment scheme uses vlad and vlad-git. However, we use rake tasks and rails generators for post-deployment. This rake task (deploy:after_update) does standard stuff like copying configuration files from samples, generates god configurations, clears stylesheet and javascript caches, notifies Hoptoad and New Relic about the deployment. It also restarts required services using god.

### Deployment structure

We use the standard vlad (== capistrano) format, with some extra:

    /path/to/app/dir    <--- app dir
        .../.rvmrc      <--- we set rvm here, and we don't have to worry about rvmrc trust
        .../current     <--- points to the current release
        .../releases    <--- contains timestamped directories for the last 5 release
        .../scm         <--- used by vlad-git
        .../shared      <--- shared files for ...
            .../bundle  <--- ... bundler
            .../log     <--- ... logs
            .../pids    <--- ... process ID's
            .../system  <--- ... symlinked to public/system
            .../config  <--- ... contains files to be symlinked to config dir

## Resources used

* Version control: [git](http://git-scm.com/)
* Ruby engine: [RVM](http://rvm.beginrescueend.com/), [Ruby 1.9.2](http://ruby-lang.org/)
* Template engine: [Slim](http://slim-lang.com/), [Sass](http://sass-lang.com/)
* Form generator: [Formtastic](http://github.com/justinfrench/formtastic)
* Javascript: [jQuery](http://www.jquery.com/), [Unobtrusive Javascript for jquery](http://github.com/rails/jquery-ujs/), [jquery-rails](http://rubygems.org/gems/jquery-rails)
* Application server: [Unicorn](http://unicorn.bogomips.org/) / [Passenger](http://www.modrails.com/)
* Watchdog: [God](http://god.rubyforge.org/)
* Deployment: [Vlad](http://rubyhitsquad.com/Vlad_the_Deployer.html)
* Unit test: [RSpec](http://rspec.info/) and [Shoulda](http://github.com/thoughtbot/shoulda)
* Behavior test: [Cucumber](http://cukes.info/)
* Web browser emulation: [Webrat](https://github.com/brynary/webrat) / [Capybara](http://github.com/jnicklas/capybara)
* Fixtures: [Factory Girl](http://github.com/thoughtbot/factory_girl)
* Authentication: [Devise](http://github.com/plataformatec/devise)
* Authorization: [CanCan](http://github.com/ryanb/cancan)

For more settings, visit [html5boilerplate.com](http://html5boilerplate.com/).
