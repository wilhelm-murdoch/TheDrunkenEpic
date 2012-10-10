app = 'thedrunkenepic'

set :application, app
set :repository, 'git@github.com:wilhelm-murdoch/TheDrunkenEpic.git'
set :scm, :git
set :scm_verbose, true
set :deploy_via, :remote_cache

# SSH/user.
set :user, 'deploy' # Might need to use root.
set :use_sudo, false
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

# Stages.
set :stages, %w(production)
set :default_stage, "production"
set :deploy_to, "/mnt/#{app}"
require 'capistrano/ext/multistage'

require 'bundler/capistrano'

load 'deploy/assets'

after "deploy:restart", "deploy:cleanup"

desc 'Used to remotely manage Bundler for updated Gems.'
namespace :bundler do
  desc "Run 'bundle install' in the latest release path."
  task :install do
    run "cd #{current_release} && bundle install --without test"
  end
  task :update do
    run "cd #{current_release} && bundle update"
  end
  task :default do
    install
  end
end

namespace :deploy do
  desc 'Restart site processes'
  task :restart do
    deploy.stop
    deploy.start
  end

  desc 'Start site processes'
  task :start do
    run "bluepill load /mnt/thedrunkenepic/current/config/pills/#{app}-#{stage}.pill --no-privileged -c /mnt/bluepill"
  end

  desc 'Stop site processes'
  task :stop do
    run "bluepill thedrunkenepic stop --no-privileged -c /mnt/bluepill; true"
  end
end
