unless ENV['ZEPILY_DEV'].to_i == 1
  $stderr.puts <<-EOF
  This is a destructive action, intended ONLY for use in development
  environments.

  If this is what you want, set the ZEPILY_DEV environment variable to 1 before
  attempting to seed your database.

  EOF
  fail('Not proceeding, missing ZEPILY_DEV=1 environment variable')
end

seed_dirs = [Rails.root.join('db', 'seeds', '*.rb'),
             Rails.root.join('db', 'seeds', 'private', '*.rb')]

seed_dirs.each do |dir|
  Dir[dir].each do |filename|
    load(filename)
  end
end
