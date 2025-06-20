    <#assign assignedEntity = cda.getLegalAuthenticator().getAssignedEntity()>
    {
    "fullUrl": "urn:uuid:${practitionerUuid}",
    "resource": {
    "resourceType": "Practitioner",
    "id": "${practitionerUuid}",
    "identifier": [
    {
    "use": "official",
    <#if assignedEntity.getIds()[0].getExtension()??>
        "value": "${(assignedEntity.getIds()[0].getExtension())!''}",
        "system": "urn:oid:${(assignedEntity.getIds()[0].getRoot())!''}"
    <#else>
        "system":"urn:ietf:rfc:3986",
        "value":"urn:oid:${(assignedEntity.getIds()[0].getRoot())!''}"
    </#if>
    }
    ],
    "name": [
    {
    "family": "${assignedEntity.getAssignedPerson().getNames()[0].getFamilies()[0].getText()}",
    "given": [
    <#list assignedEntity.getAssignedPerson().getNames()[0].getGivens() as given>
        "${given.getText()}"<#if given_has_next>, </#if>
    </#list>
    ]
    }
    ],
    "telecom": [
    {
    "system": "email",
    "value": "${assignedEntity.getTelecoms()[0].getValue()?replace('mailto:', '')}"
    }
    ],
    "address": [
    {
    "line": [
    "${practitionerStreet}"
    ],
    "city": "${practitionerCity}",
    "postalCode": "${practitionerPostalCode}",
    "country": "GR"
    }
    ]
    },
    "request": {
    "method": "POST",
    "url": "Practitioner",
    "ifNoneExist": "identifier=urn:oid:${assignedEntity.getIds()[0].getRoot()}|${assignedEntity.getIds()[0].getExtension()}"
    }
    }
    <#global gcomma = true>
