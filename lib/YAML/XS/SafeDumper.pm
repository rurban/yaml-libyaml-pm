package YAML::XS::SafeDumper;
our $VERSION = '0.70';

use YAML::XS::Dumper;
our @ISA = ('YAML::XS::Dumper', 'YAML::XS::LibYAML');

1;
