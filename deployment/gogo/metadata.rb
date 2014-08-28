name              "gogo"
maintainer        "Martin Biermann"
maintainer_email  "info@martinbiermann.com"
license           "MIT"
description       "Configures a Rocket Internet API server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"

recipe "gogo::server", "Installs GoGo server"

depends "apt"
depends "postgresql"
depends "thin_nginx"