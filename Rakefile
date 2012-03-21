require 'rubygems'
 
task :clean do
  sh "rm ralgorithms*.gem"
end

task :build do
  sh "gem build ralgorithms.gemspec"
end

task :release do
  sh "gem push `ls -lr ralgorithms*.gem | awk '{print $8}'`"
end

