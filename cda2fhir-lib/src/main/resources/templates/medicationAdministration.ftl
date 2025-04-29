<#escape x as x?json_string>
    <#assign bundleId = uuidGenerator.generate()>
    <#assign documentId = uuidGenerator.generate()>
    <#assign patientId = uuidGenerator.generate()>
    <#assign practitionerId = uuidGenerator.generate()>
    <#assign organizationId = uuidGenerator.generate()>
    <#assign medicationAdminId = uuidGenerator.generate()>
    <#assign medicationId = uuidGenerator.generate()>
    <#assign substanceId = uuidGenerator.generate()>


    {
    "resourceType": "Bundle",
    "id": "${bundleId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-medication-administration-document"
    ],
    "security": [{
    "system": "http://terminology.hl7.org/CodeSystem/v3-Confidentiality",
    "code": "${hl7message.get("/MSH-8-1")}"
    }
    ]
    },
    "language": "${hl7message.get("/MSH-19-1")}",
    "identifier": {
    "use": "official",
    "system": "${hl7message.get("/MSH-3-1")}",
    "value": "${hl7message.get("/MSH-4-1")}"
    },
    "type": "document",
    "timestamp": "${hl7message.get("/MSH-7-1")}",
    "entry": [{
    "fullUrl": "urn:uuid:${documentId}",
    "resource": {
    "resourceType": "Composition",
    "id": "${documentId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-clinical-document"
    ]
    },
    "language": "${hl7message.get("/MSH-19-1")}",
    "identifier": [{
    "use": "official",
    "system": "https://www.bd.com/CATO",
    "value": "${hl7message.get("/.NTE(1)-3-1")}"
    }
    ],
    "status": "final",
    "type": {
    "coding": [{
    "system": "http://loinc.org",
    "code": "${hl7message.get("/.NTE(0)-3-1")}",
    "display": "${hl7message.get("/.NTE(0)-4-1")}"
    }
    ]
    },
    "category": [{
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-ihe-xds-classCode",
    "code": "${hl7message.get("/.NTE(0)-1-1")}",
    "display": "${hl7message.get("/.NTE(0)-2-1")}"
    }
    ]
    }
    ],
    "subject": [{
    "reference": "urn:uuid:${patientId}",
    "display": "${hl7message.get("/PID-9-2")+hl7message.get("/PID-9-1")}"
    }
    ],
    "date": "${hl7message.get("/MSH-7-1")}",
    "author": [{
    "reference": "urn:uuid:${practitionerId}"
    }
    ],
    "title": "${hl7message.get("/.NTE2-5-1")}",
    "note": [{
    "authorString": "${hl7message.get("/PV1-7-3")} ${hl7message.get("/PV1-7-2")}",
    "text": "${hl7message.get("/.NTE2-4-1")}"
    }
    ],
    "attester": [{
    "mode": {
    "coding": [{
    "system": "http://hl7.org/fhir/composition-attestation-mode",
    "code": "${hl7message.get("/ORC-7-1")}",
    "display": "${hl7message.get("/ORC-7-2")}"
    }
    ]
    },
    "time": "${hl7message.get("/MSH-7-1")}",
    "party": {
    "reference": "urn:uuid:${practitionerId}"
    }
    }
    ],
    "custodian": {
    "reference": "urn:uuid:${organizationId}"
    },
    "section": [{
    "title": "${hl7message.get("/.NTE(1)-4-1")}",
    "code": {
    "coding": [{
    "system": "http://loinc.org",
    "code": "${hl7message.get("/.NTE(1)-2-1")}",
    "display": "${hl7message.get("/.NTE(1)-4-1")}"
    }
    ]
    },
    "entry": [{
    "reference": "urn:uuid:${medicationAdminId}"
    }
    ]
    }
    ]
    }
    }, {
    "fullUrl": "urn:uuid:${patientId}",
    "resource": {
    "resourceType": "Patient",
    "id": "${patientId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-document-patient"
    ]
    },
    "extension": [{
    "url": "http://hl7.org/fhir/StructureDefinition/patient-birthPlace",
    "valueAddress": {
    "city": "${hl7message.get("/PID-28-2")}",
    "district": "${hl7message.get("/PID-28-5")}",
    "country": "${hl7message.get("/PID-26-1")}"
    }
    }
    ],
    "identifier": [{
    "use": "official",
    "type": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
    "code": "SS",
    "display": "Social Security number"
    }
    ]
    },
    "system": "urn:oid:2.16.840.1.113883.2.25.3.4.1.1.2",
    "value": "${hl7message.get("/PID-4-1")}"
    }, {
    "use": "official",
    "type": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
    "code": "MR",
    "display": "Medical record number"
    }
    ]
    },
    "system": "https://cteam.gr/OIS",
    "value": "${hl7message.get("/PID-2-1")}"
    }
    ],
    "name": [{
    "use": "official",
    "family": "${hl7message.get("/PID-5-1")}",
    "_family": {
    "extension": [{
    "url": "http://hl7.org/fhir/StructureDefinition/humanname-mothers-family",
    "valueString": "${hl7message.get("/PID-6-1")}
    }
    ]
    },
    "given": [
    "${hl7message.get("/PID-5-2")}"
    ]
    }, {
    "extension": [{
    "url": "http://hl7.org/fhir/StructureDefinition/iso21090-EN-use",
    "valueCode": "ABC"
    }
    ],
    "use": "official",
    "family": "${hl7message.get("/PID-9-1")}",
    "given": [
    "${hl7message.get("/PID-9-2")}"
    ]
    }
    ],
    "telecom": [{
    "system": "email",
    "value": "${hl7message.get("/PID-13-4")}",
    "use": "home"
    }, {
    "system": "phone",
    "value": "${hl7message.get("/PID-13-1")}",
    "use": "home"
    }
    ],
    <#if hl7message.get("/PID-8-1") == "MALE" || hl7message.get("/PID-8-1") == "male" || hl7message.get("/PID-8-1") == "m"|| hl7message.get("/PID-8-1") == "M">
        "gender": "male",
    <#else>
        "gender": "female"
    </#if>
    "birthDate": "${hl7message.get("/PID-7-1")}",
    "address": [{
    "use": "${hl7message.get("/PID-11-7")}",
    "line": [
    "${hl7message.get("/PID-11-1")}"
    ],
    "city": "${hl7message.get("/PID-11-3")}",
    "postalCode": "${hl7message.get("/PID-11-4")}",
    "country": "${hl7message.get("/PID-12-1")}"
    }
    ]
    }
    }, {
    "fullUrl": "urn:uuid:${practitionerId}",
    "resource": {
    "resourceType": "Practitioner",
    "id": "${practitionerId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-document-practitioner"
    ]
    },
    "identifier": [{
    "use": "official",
    "type": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
    "code": "MD",
    "display": "Medical License number"
    }
    ]
    },
    "system": "urn:oid:2.16.840.1.113883.2.25.3.4.1.1.3",
    "value": "${hl7message.get("/PV1-7-7")}"
    }, {
    "use": "official",
    "type": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
    "code": "PRN",
    "display": "Provider number"
    }
    ]
    },
    "system": "http://www.gnomon.com.gr/hpd",
    "value": "${hl7message.get("/PV1-11-1")}"
    }
    ],
    "active": true,
    "name": [{
    "family": "${hl7message.get("/PV1-7-2")}",
    "given": [
    "${hl7message.get("/PV1-7-3")}"
    ]
    }
    ],
    "qualification": [{
    "code": {
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-oaps-practitioner-specialty",
    "code": "${hl7message.get("/PV1-7-11")}",
    "display": "${hl7message.get("/PV1-7-5")}"
    }
    ]
    }
    }
    ]
    }
    }, {
    "fullUrl": "urn:uuid:${organizationId}",
    "resource": {
    "resourceType": "Organization",
    "id": "${organizationId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-document-organization"
    ]
    },
    "identifier": [{
    "use": "official",
    "type": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
    "code": "PRN",
    "display": "Provider number"
    }
    ]
    },
    "system": "http://www.gnomon.com.gr/hpd",
    "value": "${hl7message.get("/PV1-11-1")}"
    }
    ],
    "active": true,
    "type": [{
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-oaps-organization-type",
    "code": "${hl7message.get("/PV1-11-4")}",
    "display": "${hl7message.get("/PV1-11-5")}"
    }
    ]
    }
    ],
    "name": "${hl7message.get("/PV1-11-1")}"
    }
    }, {
    "fullUrl": "urn:uuid:${medicationAdminId}",
    "resource": {
    "resourceType": "MedicationAdministration",
    "id": "${medicationAdminId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-medication-administration"
    ]
    },
    "identifier": [{
    "use": "usual",
    "type": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
    "code": "FILL",
    "display": "Filler Identifier"
    }
    ]
    },
    "system": "https://www.bd.com/CATO",
    "value": "DISPENSATION-ID-IN-REPO"
    }
    ],
    "status": "completed",
    "category": [{
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/medication-admin-location",
    "code": "inpatient",
    "display": "${hl7message.get("/RXA-11-1")}"
    }
    ]
    }
    ],
    "medication": {
    "reference": {
    "reference": "urn:uuid:${medicationId}"
    }
    },
    "subject": {
    "reference": "urn:uuid:${patientId}"
    },
    "occurrenceDateTime": "${hl7message.get("/RXA-3-1")}",
    "isSubPotent": false,
    "performer": [{
    "function": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/med-admin-perform-function",
    "code": "performer",
    "display": "Performer"
    }
    ]
    },
    "actor": {
    "reference": {
    "reference": "urn:uuid:${practitionerId}"
    }
    }
    }
    ],
    "reason": [{
    "concept": {
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/reason-medication-given",
    "code": "${hl7message.get("/RXA-9-1")}",
    "display": "${hl7message.get("/RXA-9-2")}"
    }
    ]
    }
    }
    ],
    "request": {
    "type": "MedicationRequest",
    "identifier": {
    "system": "http://www.gnomon.com.gr/cdr",
    "value": "PRESCRIPTION-DOC-ID-IN-REPO"
    }
    },
    "dosage": {
    "site": {
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-edqm-intended-site",
    "code": "${hl7message.get("/RXR-2-1")}",
    "display": "${hl7message.get("/RXR-2-2")}"
    }
    ]
    },
    "route": {
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-edqm-route-and-method-of-administration",
    "code": "${hl7message.get("/RXR-1-1")}",
    "display": "${hl7message.get("/RXR-1-2")}"
    }
    ]
    },
    "method": {
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-edqm-administration-method",
    "code": "${hl7message.get("/RXR-4-1")}",
    "display": "${hl7message.get("/RXR-4-2")}"
    }
    ]
    },
    "dose": {
    "value": ${hl7message.get("/RXR-5-1")},
    "unit": "${hl7message.get("/RXR-5-2")}",
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-oaps-measures",
    "code": "${hl7message.get("/RXR-5-5")}"
    }
    }
    }
    }, {
    "fullUrl": "urn:uuid:${medicationId}",
    "resource": {
    "resourceType": "Medication",
    "id": "${medicationId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-medication"
    ]
    },
    "doseForm": {
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-edqm-basic-dose-form",
    "code": "${hl7message.get("/RXA-8-1")}",
    "display": "${hl7message.get("/RXA-8-2")}"
    }
    ]
    },
    "ingredient": [{
    "item": {
    "reference": {
    "reference": "urn:uuid:${substanceId}"
    }
    },
    "isActive": true,
    "strengthQuantity": {
    "value": ${hl7message.get("/RXA-6-1")},
    "unit": "${hl7message.get("/RXA-7-2")}",
    "system": "${hl7message.get("/RXA-7-1")}",
    "code": "${hl7message.get("/RXA-7-2")}"
    }
    }
    ]
    }
    }, {
    "fullUrl": "urn:uuid:${substanceId}",
    "resource": {
    "resourceType": "Substance",
    "id": "${substanceId}",
    "meta": {
    "profile": [
     "http://www.gnomon.com.gr/ig/oaps/StructureDefinition/oaps-substance"
    ]
    },
    "instance": false,
    "status": "inactive",
    "category": [{
    "coding": [{
    "system": "http://terminology.hl7.org/CodeSystem/substance-category",
    "code": "${hl7message.get("/RXA-5-3")}",
    "display": "${hl7message.get("/RXA-5-2")}"
    }
    ]
    }
    ],
    "code": {
    "concept": {
    "coding": [{
    "system": "http://www.gnomon.com.gr/ig/oaps/CodeSystem/cs-atc",
    "code": "${hl7message.get("/RXA-5-6")}",
    "display": "${hl7message.get("/RXA-5-5")}"
    }
    ]
    }
    }
    }
    }
    ]
    }
</#escape>