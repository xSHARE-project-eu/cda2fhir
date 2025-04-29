# CDA2FHIR

Converts HL7 CDA (Clinical Document Architecture) documents to HL7 FHIR (Fast Healthcare Interoperability Resources) International Patient Summary (IPS) format for improved healthcare data interoperability.

## Project Overview

This project consists of two main components:

1. **cda2fhir-lib**: A Java library that transforms HL7 CDA documents to HL7 FHIR IPS format using Freemarker templates.
2. **cda2fhir-service**: A Spring Boot REST service that exposes the transformation functionality via a web API.

The transformation process extracts relevant information from CDA documents such as patient details, organization information, and practitioner data, and maps them to corresponding FHIR resources.

## Prerequisites

- Java 21
- Maven 3.8+
- Docker (for containerization)

## Building the Project

### Building with Maven

To build both projects, run the following commands from the project root:

```bash
# Build the library first
cd cda2fhir-lib
mvn clean install

# Build the service
cd ../cda2fhir-service
mvn clean package
```

This will compile the code, run tests, and package the applications.

### Creating Docker Images

You can create Docker images for the service using Spring Boot's built-in support:

```bash
# Make sure you've built the library first
cd cda2fhir-lib
mvn clean install

# Build the Docker image for the service
cd ../cda2fhir-service
mvn spring-boot:build-image
```

This will create a Docker image named `cda2fhir-service:1.0.0`.

## Running the Application

### Running Locally with Maven

To run the service locally using Maven:

```bash
cd cda2fhir-service
mvn spring-boot:run
```

The service will be available at http://localhost:8080/cda2fhir/transform

### Running with Docker Compose

A Docker Compose file is provided to run the service in a containerized environment:

1. Make sure you've built the Docker image as described above
2. From the project root, run:

```bash
docker compose up -d
```

The service will be available at http://localhost:8080/cda2fhir/transform

## API Usage

The service exposes a single endpoint for transforming CDA documents:

- **Endpoint**: `/transform`
- **Method**: POST
- **Content-Type**: application/xml
- **Accept**: application/json
- **Request Body**: HL7 CDA document in XML format
- **Response**: HL7 FHIR IPS document in JSON format

### Example Usage with cURL

```bash
curl -X POST \
  http://localhost:8080/cda2fhir/transform \
  -H 'Content-Type: application/xml' \
  -d @path/to/your/cda-document.xml
```

## Error Handling

The service returns appropriate HTTP status codes for different error scenarios:

- **400 Bad Request**: If the input is not a valid CDA document
- **500 Internal Server Error**: If there's an error during the transformation process

## Development Notes

- The transformation is performed using Freemarker templates located in the `cda2fhir-lib/src/main/resources/templates` directory.
- The service uses Spring Boot 3.4.5 and requires Java 21.

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.
