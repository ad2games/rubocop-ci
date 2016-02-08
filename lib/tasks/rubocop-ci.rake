require 'rake'
require 'yaml'

require 'rubocop/rake_task'
require 'scss_lint/rake_task'
require 'coffeelint'
require 'slim_lint'
require 'slim_lint/rake_task'
require 'brakeman'

rubocop_config = nil

def config_file(name)
  File.expand_path("../../../config/#{name}", __FILE__)
end

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = gem_config = config_file('rubocop.yml')
  todo_config = "#{Dir.pwd}/.rubocop_todo.yml"

  if File.exist?(todo_config)
    rubocop_config = Tempfile.new('rubocop')
    rubocop_config.write(YAML.dump('inherit_from' => [gem_config, todo_config.to_s]))
    rubocop_config.close
    config = rubocop_config.path
  end

  # SlimLint runs rubocop on .slim files. Ensure we use the same config for .rb and .slim files.
  ENV['SLIM_LINT_RUBOCOP_CONF'] = config

  task.options = ['-D', '-c', config]
  task.options << '-R' if defined?(Rails)
  task.options << '--auto-gen-config' if ENV['AUTOGEN']
  task.requires = ['rubocop-rspec']
end

if Dir.exist?('app')
  scss_task = File.exist?("#{Dir.pwd}/.skip_scss_lint") ? :scss_lint : :rubocop
  SCSSLint::RakeTask.new(scss_task) do |task|
    task.config = config_file('scss-lint.yml')
    task.files = ['app/assets']
  end

  task :rubocop do
    config = File.expand_path('../../../config/coffeelint.json', __FILE__)
    failures = Coffeelint.run_test_suite('app', config_file: config)
    raise('Coffeelint fail!') if failures > 0
  end

  SlimLint::RakeTask.new(:rubocop) do |task|
    task.config = config_file('slim-lint.yml')
    task.files = %w(app spec)
  end

  task :rubocop do
    install = 'npm install standard -g'
    sh install if ENV['CI']
    raise "Please install standard: #{install}" unless system('which standard')

    sh 'standard'
  end

  task :rubocop do
    result = Brakeman.run(app_path: '.', exit_on_warn: true)
    ignored = result.ignored_filter ? result.ignored_filter.ignored_warnings : []
    errors = result.errors + result.warnings - ignored

    if errors.empty?
      puts 'Brakeman OK'
    else
      puts result.report.to_s
      raise 'Brakeman Errors'
    end
  end
end
