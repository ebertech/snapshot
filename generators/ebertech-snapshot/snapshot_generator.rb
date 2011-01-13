class SnapshotGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      dir = File.join("features", "support")
      file = File.join(dir, "snapshot.rb")
      m.directory dir
      m.template "snapshot.rb", file
    end
  end
end