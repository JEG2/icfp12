require "fileutils"
require "pathname"

SUBMISSION_DIR = Pathname("icfp-96554412")
SRC_DIR        = SUBMISSION_DIR + "src"

def copy_all_to_src(dir)
  from  = Pathname(dir)
  to    = SRC_DIR + dir
  files = `git ls-files #{from}`
  to.mkpath unless to.exist?
  files.each_line do |file|
    file.strip!
    target = SRC_DIR + file
    target.dirname.mkpath
    FileUtils.cp(file, target)
  end
end

def add_file(name, content, executable = true)
  path = SUBMISSION_DIR + name
  File.write(path, content.gsub(/^\s+/, ""))
  FileUtils.chmod("+x", path)
end

desc "Prepare code for submission"
task :prepare do
  SUBMISSION_DIR.rmtree if SUBMISSION_DIR.exist?
  SRC_DIR.mkpath

  %w[bin data lib spec].each do |dir|
    copy_all_to_src(dir)
  end
  FileUtils.cp("README.md", SRC_DIR + "README")
  FileUtils.cp("Rakefile",  SRC_DIR + "Rakefile")

  add_file("install", <<-END_BASH)
  #!/bin/bash
  END_BASH
  add_file("lifter", <<-END_BASH)
  #!/bin/bash
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  exec "$DIR/src/bin/run"
  END_BASH
  add_file("PACKAGES-TESTING", <<-END_BASH, false)
  ruby1.9.1
  END_BASH

  system("tar -czf #{SUBMISSION_DIR}.tgz #{SUBMISSION_DIR}")
end

task default: :prepare
