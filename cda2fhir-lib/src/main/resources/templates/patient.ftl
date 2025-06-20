    <#assign recordTarget = cda.getRecordTargets()[0]>
    <#assign patient = recordTarget.getPatientRole().getPatient()>
    <#assign birthTime = patient.getBirthTime().getValue()>
    {
    "fullUrl": "urn:uuid:${patientUuid}",
    "resource": {
    "resourceType": "Patient",
    "id": "${patientUuid}",
    "identifier": [
    <#list recordTarget.getPatientRole().getIds() as id>
        {
        "use": "official",
        <#if id.getExtension()??>
            "value": "${(id.getExtension())!''}",
            "system": "urn:oid:${(id.getRoot())!''}"
        <#else>
            "system":"urn:ietf:rfc:3986",
            "value":"urn:oid:${(id.getRoot())!''}"
        </#if>
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
    <#if telecomPatient??>
        "telecom": [
        {
        "system": "phone",
        "value": "${telecomPatient}",
        "use": "home"
        }
        ],
    </#if>
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
