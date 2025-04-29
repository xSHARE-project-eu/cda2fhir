<#escape x as x?json_string>
    <#assign recordTarget = cda.getRecordTargets()[0]>
    <#assign patient = recordTarget.getPatientRole().getPatient()>
    <#assign birthTime = patient.getBirthTime().getValue()>
    {
    "resource": {
    "resourceType": "Patient",
    "id": "${patientUuid}",
    "identifier": [
    <#list recordTarget.getPatientRole().getIds() as id>
        {
        "use": "official",
        "system": "urn:oid:${id.getExtension()}",
        "value": "${id.getRoot()}"
        }<#if id_has_next>,</#if>
    </#list>
    ],
    "name": [
    {
    "family": "${patient.getNames()[0].getFamilies()[0].getMixed()[0].getValue()}",
    "given": [
    "${patient.getNames()[0].getGivens()[0].getMixed()[0].getValue()}"
    ]
    }
    ],
    "telecom": [
    {
    "system": "phone",
    "value": "${telecomPatient}",
    "use": "home"
    }
    ],
    <#if patient.getAdministrativeGenderCode().getCode() == "F" >
        "gender": "female",
    </#if>
    <#if patient.getAdministrativeGenderCode().getCode() == "M" >
        "gender": "male",
    </#if>
    "birthDate": "${birthTime?substring(0, 4)?default('')}-${birthTime?substring(4, 6)?default('')}-${birthTime?substring(6, 8)?default('')}",
    "address": [
    {
    "line": [
    "${addr}"
    ],
    "city": "${city}",
    "postalCode": "${postalCode}",
    "country": "${country}"
    }
    ]
    },
    "request": {
    "method": "POST",
    "url": "Patient"
    }
    }
    <#global gcomma = true>
</#escape>
