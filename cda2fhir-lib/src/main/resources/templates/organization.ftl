<#escape x as x?json_string>
    <#assign organization = cda.getCustodian().getAssignedCustodian().getRepresentedCustodianOrganization()>
    {
    "resource": {
    "resourceType": "Organization",
    "id": "${uuid.generate()}",
    "identifier": [
    <#list organization.getIds() as id>
        {
        "use": "official",
        "system": "urn:oid:${id.getExtension()}",
        "value": "${id.getRoot()}"
        }<#if id_has_next>,</#if>
    </#list>
    ],
    <#assign nameMixed = organization.getName()?if_exists.getMixed()?if_exists>
    "name": <#if (nameMixed?size > 0)>"${nameMixed[0].getValue()?default('')}"</#if>,
    <#if (organization.getTelecom().getValue())??>
        "telecom": [
        {
        "system": "email",
        "value": "${(organization.getTelecom().getValue())!""}",
        "use": "work"
        }
        ],
    </#if>
    "address": {
    "line": [
    "${streetOrg}"
    ],
    "city": "${cityOrg}",
    "postalCode": "${postalCodeOrg}",
    "country": "GR"
    }
    },
    "request": {
    "method": "POST",
    "url": "Organization"
    }
    }
    <#global gcomma = true>
</#escape>
