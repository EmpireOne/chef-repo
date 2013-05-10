name             'projects'
maintainer       'EmpireOne Group Pty Ltd'
maintainer_email 'sysadmin@empireone.com.au'
license          'All rights reserved'
description      'Installs/Configures a given project'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

# dependencies are not properly defined. depends "apache2" should be used here
# however I don't undertand their implication well enough. the EmpireOne projects
# cookbook will install and php pased or rails based projects, hence have different
# dependencie sets..

depends "mysql"