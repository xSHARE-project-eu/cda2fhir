    <#assign organization = cda.getCustodian().getAssignedCustodian().getRepresentedCustodianOrganization()>
    <#assign organizationUuid = uuid.generate()>
    {
    "fullUrl": "urn:uuid:${organizationUuid}",
    "resource": {
    "resourceType": "Organization",
    "id": "${organizationUuid}",
    "identifier": [
    <#list organization.getIds() as id>
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
    <#assign nameMixed = organization.getName()?if_exists.getMixed()?if_exists>
    "name": <#if (nameMixed?size > 0)>"${nameMixed[0].getValue()?default('')}"</#if>
    <#if (organization.getTelecom().getValue())??>
        ,
        "telecom": [
        {
        "system": "email",
        "value": "${(organization.getTelecom().getValue())!""}",
        "use": "work"
        }
        ],
    </#if>
    <#if streetOrg?? && cityOrg?? && postalCodeOrg??>
        "address": {
        "line": [
        "${streetOrg}"
        ],
        "city": "${cityOrg}",
        "postalCode": "${postalCodeOrg}",
        "country": "GR"
        }
    </#if>
    },
    "request": {
    "method": "POST",
    "url": "Organization"
    }
    }
    <#global gcomma = true>
