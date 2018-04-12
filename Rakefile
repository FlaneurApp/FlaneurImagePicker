# Rakefile for common CLI commands.

desc "Install pods"
task :pod_install => [ :pod_repo_update ] do |t|
  sh "bundle exec pod install --project-directory=Example"
end

desc "Update pods"
task :pod_update => [ :pod_repo_update ] do |t|
  sh "bundle exec pod update --project-directory=Example"
end

desc "Update pods repos"
task :pod_repo_update do |t|
  sh "bundle exec pod repo update"
end

desc "Open"
task :open do |t|
  sh "cd Example && open FlaneurImagePicker.xcworkspace"
end

desc "Generate documentation"
task :doc do |t|
  sh "bundle exec jazzy"
end

desc "Prepare commit"
task :prepare_commit => [ :doc, :pod_install ] do |t|
  puts "Now ready for commit"
end
