require 'rake/testtask'
Rake::TestTask.new("spec") do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList['spec/*_spec.rb']
end

desc "Run specs with all adapters"
task "spec:all" do
  system( "rake spec ; rake spec ORM=ar" )
end

task :default => "spec:all"
