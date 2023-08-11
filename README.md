# Pseudo EHR

![FHIR R4](https://img.shields.io/badge/FHIR-R4-orange)
![Ruby 3.1.3](https://img.shields.io/badge/Ruby-3.1.3-red)

The Pseudo EHR is a demo FHIR client software for the Public Health FHIR Implementation Collaborative (PHFIC). **Runs on port 8080**


## Dependencies
 - Ruby 3.1.3
 - [Bundler](https://bundler.io/)


## Quick Start

To pull in remote `pseudo-ehr` from github for local development:

```
cd ~/path/to/your/workspace/
git clone https://github.com/phfic/pseudo-ehr.git
cd pseudo-ehr
```

To install Ruby dependencies:

```
bundle install
```

To launch server:

```
rails s
```

To use the web client, open your web browser to <http://localhost:8080> and connect to FHIR server `http://hapi.fhir.org/baseR4`.

## Dev Notes
 - [ ] `welcome_controller` manages index, server_url/condition input, and redirect to encounters controller
 - [ ] `encounters_controller` renders data grid of Syphilis cases (encounters)
 - [ ] `encounters#show` renders an entire case
 - [ ] `encounters#edit`, `encounters#update`, & `encounters#destroy` give you full manual stewardship over data
 - [ ] `encounters#new` lets you input a new Syphilis case, and `encounters#create` does FHIR create on server
 - [ ] consider new controller/action for aggregate/geographic data rendering
 - [ ] `rails t test/integration/phfic_test.rb` tests the above

## Copyright

Copyright 2023 The MITRE Corporation
