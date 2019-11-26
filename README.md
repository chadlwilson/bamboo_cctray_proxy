# Bamboo-to-CCTray Proxy

[![Build pipeline status badge](https://github.com/chadlwilson/bamboo_cctray_proxy/workflows/Ruby/badge.svg)](https://github.com/chadlwilson/bamboo_cctray_proxy/actions) ![License](https://img.shields.io/github/license/chadlwilson/bamboo_cctray_proxy)

Bamboo-to-CCTray is a small Ruby proxy application that can expose Atlassian Bamboo continuous integration build statuses 
in the [CCTray XML format](https://cctray.org/), originally inspired by CruiseControl, and still supported by 
most CI servers (cloud and non-cloud-based). But not Bamboo!

This allows the many tools written to support monitoring of builds to be used with Atlassian Bamboo builds. 
Examples of such tools are build radiator/monitor tools such as [NeverGreen](https://github.com/build-canaries/nevergreen)
and user notification tools such as CCMenu

This was [originally developed in 2010](http://bitbucket.org/amanking/to_cctray/) by [@amanking](https://github.com/amanking), 
and later ported to GitHub, moved to modern Ruby, Bamboo REST API (rather than RSS feeds), Dockerized and augmented
to support monitoring entire Bamboo projects.

## Examples

Bamboo builds on [NeverGreen](https://github.com/build-canaries/nevergreen) (with healthy builds showing; for clarity)
![Example Monitor page](examples/screenshot_nevergreen_dashboard.png)

Auto-detection of Bamboo builds:
![Example Tracking page](examples/screenshot_nevergreen_tracking.png)

Example [CCTray formatted output](https://cctray.org/) snippet driving the above
```xml
<Projects>
    <Project lastBuildLabel="69" lastBuildTime="2019-07-02T06:24:03Z" name="Server - Kubernetes 1.11 - 1.7.x"
             webUrl="https://build.spring.io/rest/api/latest/result/SCD-K8S19B15X-69" activity="Sleeping"
             lastBuildStatus="Success"/>
    <Project lastBuildLabel="101" lastBuildTime="2019-11-13T19:23:08Z" name="Spring Cloud Data Flow Samples"
             webUrl="https://build.spring.io/rest/api/latest/result/SCD-SCDFSAMPLES-101" activity="Sleeping"
             lastBuildStatus="Failure"/>
    <Project lastBuildLabel="175" lastBuildTime="2019-11-26T14:52:21Z" name="projectreactor.io"
             webUrl="https://build.spring.io/rest/api/latest/result/REACTOR-RSITE-175" activity="Sleeping"
             lastBuildStatus="Success"/>
    <!-- SNIPPED -->
</Projects>
```


You can see this example yourself in [./examples](./examples/docker-compose.yml) and run with
```bash
git clone git@github.com:chadlwilson/bamboo_cctray_proxy.git && cd bamboo_cctray_proxy.git/examples
docker-compose up
```

## Usage

1. Setup your configuration in `config/bamboo.xml`
1. Run it by one of the mechanisms below
1. Navigate to http://localhost:7000/dashboard/cctray.xml to view the feed; point your tools at this

### Docker

```bash
mkdir -p config && touch config/bamboo.yml # Put your config here
docker run -p 7000:7000 -v $(pwd)/config:/app/config chadwilson/bamboo_cctray_proxy:latest
```

### Running from source

```bash
git clone git@github.com:chadlwilson/bamboo_cctray_proxy.git && cd bamboo_cctray_proxy
bundle install --without=test
cd ramaze && ruby -rrubygems start.rb
```

## Configuration

The Bamboo servers and builds to monitor are specified in `config/bamboo.yml`. 

Example configuration:
```yaml
# Monitor specific builds by their build plan keys
- spring_cloud_data_builds:
    url: https://build.spring.io
    build_keys:
      - SCD-K8S19B15X
      - SCD-SCDFSAMPLES

# Monitor entire projects with their project keys
- spring_reactor_project:
    url: https://build.spring.io
    projects:
      - REACTOR

# You can use either of the patterns above with a secured Bamboo server
# Note; the password is in plain-text.
- secured_bamboo:
    url: https://secret.bamboo.org
    basic_auth:
      username: username
      password: password
    build_keys:
      - ABC

# Returns ALL plans the user has permissions to view on the server.
# Be careful; this probably won't perform well; especially not on a public server!
- secured_bamboo_all_plans:
    url: https://secret.bamboo.org
    basic_auth:
      username: username
      password: password
```

# Resources

* Atlassian Bamboo: http://www.atlassian.com/software/bamboo/
* CCTray XML format: https://cctray.org/
* NeverGreen: https://github.com/build-canaries/nevergreen
* CCMenu (Mac OS X): http://ccmenu.sourceforge.net/
* BuildNotify (Linux): http://bitbucket.org/Anay/buildnotify/
