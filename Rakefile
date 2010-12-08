require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
# for adapter in %w( mysql postgresql sqlite sqlite3 firebird db2 oracle sybase openbase frontbase jdbcmysql jdbcpostgresql jdbcsqlite3 jdbcderby jdbch2 jdbchsqldb )
for adapter in %w( mysql )
  Rake::TestTask.new("test_#{adapter}") { |t|
    if adapter =~ /jdbc/
      t.libs << "test" << "test/connections/jdbc_#{adapter}"
    else
      t.libs << "test" << "test/connections/native_#{adapter}"
    end
    adapter_short = adapter == 'db2' ? adapter : adapter[/^[a-z]+/]
    t.test_files=Dir.glob( "test/cases/**/*_test{,_#{adapter_short}}.rb" ).sort
    t.verbose = true
  }

  namespace adapter do
    task :test => "test_#{adapter}"
  end
end