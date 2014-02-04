require 'rubygems'
require 'bundler'
require 'rake'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

desc 'Default: run the specs and features.'
task :default do
  system('bundle exec rake -s appraisal spec:unit spec:acceptance features;')
end

namespace :spec do
  desc 'Run unit specs'
  RSpec::Core::RakeTask.new('unit') do |t|
    t.pattern = 'spec/{*_spec.rb,factory_girl/**/*_spec.rb}'
  end

  desc 'Run acceptance specs'
  RSpec::Core::RakeTask.new('acceptance') do |t|
    t.pattern = 'spec/acceptance/**/*_spec.rb'
  end
end

desc 'Run the unit and acceptance specs'
task :spec => ['spec:unit', 'spec:acceptance']