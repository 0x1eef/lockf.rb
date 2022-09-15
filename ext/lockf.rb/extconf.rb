require "mkmf"

[
  'INSTALL_DATA', 'INSTALL_SCRIPT', 
  'INSTALL_PROGRAM', 'INSTALL_DATA', 
  'INSTALL'
].each do
  CONFIG[_1].sub!(/-o [a-zA-Z0-9]+/, '')
  CONFIG[_1].sub!(/-g [a-zA-Z0-9]+/, '')
end

create_makefile "./lockf/lockf.rb"
