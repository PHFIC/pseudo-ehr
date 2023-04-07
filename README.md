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

To use the web client, open your web browser to <http://localhost:8080> and connect to FHIR server `http://hapi.fhir.org/baseR4`. This will lead you to a pagination of all patients. Use the search bar in the top right to search for `Spade`. The FHIR search should return one patient and you can open its profile. **TEST PATIENT: Sam Spade, ID: 8127768**.


## Copyright

Copyright 2023 The MITRE Corporation
