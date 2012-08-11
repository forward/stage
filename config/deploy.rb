require 'bundler'
Bundler.require :development
require 'bundler/capistrano'
require 'capistrano/deploy/tagger'
require 'fwd/capistrano'

after "deploy:update",         "foreman:export"
after "deploy:update",         "deploy:cleanup"
# after "deploy:create_symlink", "update_shared_folder_symlinks"

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :application,   "stage"

set :user,          "deploy"
set :deploy_to,     "/opt/stage"
set :keep_releases, 5

set :scm,           :git
set :repository,    "git@github.com:forward/stage.git"
set :branch,        "master"
set :scm_verbose,   true
set :use_sudo,      false
set :shared_children, %w{ csv log }

server 'streaming', :app, :web, :db, :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "#{sudo} /etc/init.d/apache2 reload"
    run "sudo start oasis || sudo restart oasis"
  end
end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export do
    run "cd #{release_path} && sudo bundle exec foreman export upstart /etc/init -p 10000 -t config/upstart -a stage -c encoder=1 -u deploy -l #{shared_path}/log"
  end
  
  desc "Start the application services"
  task :start do
    sudo "start stage"
  end

  desc "Stop the application services"
  task :stop do
    sudo "stop stage"
  end
end

task :update_shared_folder_symlinks do
  run "#{sudo} ln -s #{shared_path}/csv #{release_path}/csv"
end

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"