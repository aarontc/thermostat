require 'bundler/gem_tasks'



require 'rake/testtask'

namespace :test do
	Rake::TestTask.new(:unit) do |t|
		t.libs << %w[lib test]
		t.test_files = FileList['test/**/test_*.rb']
	end

	desc 'Clean up output'
	task :clean do
		require 'minitest/ci'
		Minitest::CI.report_dir = 'build/output/test'
		Minitest::Ci.new.start
	end

	multitask :all => %w[unit]
end

desc 'Runs all test suites (optionally specify TEST="test/test_something.rb" to run only test_something.rb)'
task :test => %w[test:all]
