<#escape x as x?json_string>
    <#list cda.getComponent().getStructuredBody().getComponents() as component>

        <#if component.getSection()?has_content && component.getSection().getCode().getCode() == "47519-4">
            <#list component.getSection().getEntries() as entry>
                <#assign procedureUuid=uuid.generate()>
                {
                "fullUrl": "urn:uuid:${procedureUuid}",
                "resource": {
                "resourceType": "Procedure",
                "id": "${procedureUuid}",
                <#if (component.getSection().getId())?? >
                    "identifier": [
                    {
                    "use": "official",
                    <#if component.getSection().getId().getExtension()??>
                        "value": "${(component.getSection().getId().getExtension())!''}",
                        "system": "urn:oid:${(component.getSection().getId().getRoot())!''}"
                    <#else>
                        "system":"urn:ietf:rfc:3986",
                        "value":"urn:oid:${(component.getSection().getId().getRoot())!''}"
                    </#if>
                    }
                    ],
                </#if>
                "status": "${(entry.getProcedure().getStatusCode().getCode())!"unknown"}",
                <#if (entry.getProcedure().getCode())??>
                    "code": {
                    "coding": [
                    {
                    "system": "http://snomed.info/sct"
                    <#if (entry.getProcedure().getCode().getCode())?? >
                        ,
                        "code": "${(entry.getProcedure().getCode().getCode())!""}"
                    </#if>
                    <#if (entry.getProcedure().getCode().getDisplayName())?? >
                        ,
                        "display": "${(entry.getProcedure().getCode().getDisplayName())!""}"
                    </#if>
                    }
                    ]
                    },
                </#if>
                "subject": {
                "reference": "urn:uuid:${patientUuid}",
                "display": "Patient"
                },
                <#if (entry.getProcedure().getEffectiveTime().getLow().getValue())??>
                    "performedString": ${entry.getProcedure().getEffectiveTime().getLow().getValue()}
                <#else>
                    "performedPeriod" : {
                    "extension" : [
                    {
                    "url" : "http://hl7.org/fhir/StructureDefinition/data-absent-reason",
                    "valueCode" : "unknown"
                    }
                    ]
                    }
                </#if>
                },
                "request": {
                "method": "POST",
                "url": "Procedure"
                <#if (component.getSection().getId())?? >
                    ,
                    "ifNoneExist": "identifier=${(component.getSection().getId().getRoot())!""}|${(component.getSection().getId().getExtension())!""}"
                </#if>
                }
                }<#if entry_has_next>,</#if>
            </#list>
            <#global gcomma = true>
        </#if>
    </#list>
</#escape>