# Bamboo-to-CCTray Proxy

Bamboo-to-CCTray is a small Ruby proxy application that can expose Atlassian Bamboo continuous integration build statuses 
in CruiseControl's CCTray XML format.

When delivered over HTTP, this allows the many tools written to support monitoring of CruiseControl builds to be 
used with Atlassian Bamboo builds. Examples of such tools are CCMenu, CCTray and Build Radiator/Monitor tools such as 
[NeverGreen](https://github.com/build-canaries/nevergreen)

## History

This was [originally developed in 2010](http://bitbucket.org/amanking/to_cctray/) by @amanking. @chadlwilson ported this to 
GitHub, Dockerized it and made it work on modern Ruby.

## Usage

1. `git clone git@github.com:chadlwilson/bamboo_cctray_proxy.git`
1. Setup your configuration in `config/bamboo.xml`
1. Run it by one of the mechanisms below
1. Navigate to http://localhost:7000/dashboard/cctray.xml to view the feed; point your tools at this

### Docker

```
docker build . -t bamboo_cctray_proxy
docker run -p 7000:7000 -v $(pwd)/config:/app/config proxy
```

### Using Ruby directly

```
bundle install --without=test
cd ramaze && ruby -rrubygems start.rb
```

## Configuration

The Bamboo servers and builds to monitor are specified in `config/bamboo.yml`. 

Example configuration:
```yaml
- spring_bamboo:
    url: https://build.spring.io
    build_keys:
        - SCD-K8S19B15X
        - SCD-SCDFSAMPLES
- secured_bamboo:
    url: https://secret.bamboo.org
    basic_auth:
      username: username
      password: password
    build_keys:
      - ABC
```

# Resources

Atlassian Bamboo: http://www.atlassian.com/software/bamboo/
CruiseControl: http://cruisecontrol.sourceforge.net/
CCTray (Windows): http://confluence.public.thoughtworks.org/display/CCNET/CCTray
CCMenu (Mac OS X): http://ccmenu.sourceforge.net/
BuildNotify (Linux): http://bitbucket.org/Anay/buildnotify/
CCTray XML format: http://confluence.public.thoughtworks.org/display/CI/Multiple+Project+Summary+Reporting+Standard
Nokogiri XML parser: http://nokogiri.org/