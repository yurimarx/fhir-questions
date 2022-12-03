 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/fhir-questions)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-fhir-template&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2fhir-questions)
 [![Reliability Rating](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Ffhir-questions&metric=reliability_rating)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Ffhir-questions)
# fhir-questions
This an application to create and collect responses from questionnaires into a FHIR Server

It setups a FHIR SERVER, imports the test data, demoes REST API usage with a simple web page.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/yurimarx/fhir-questions.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d
```

## Web app frontend
1. Open the webapp: http://localhost:52773/fhirquestions/index.html

