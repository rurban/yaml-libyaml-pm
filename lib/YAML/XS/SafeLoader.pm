package YAML::XS::SafeLoader;
our $VERSION = '0.70';

use YAML::XS::Loader;
our @ISA = ('YAML::XS::Loader', 'YAML::XS::LibYAML');

1;
