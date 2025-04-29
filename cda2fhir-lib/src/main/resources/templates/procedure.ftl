<#escape x as x?json_string>
    <#list cda.getComponent().getStructuredBody().getComponents() as component>

        <#if component.getSection()?has_content && component.getSection().getCode().getCode() == "47519-4">
            <#list component.getSection().getEntries() as entry>
                {
                "resource": {
                "resourceType": "Procedure",
                "id": "${uuid.generate()}",
                <#if (component.getSection().getId())?? >
                    "identifier": [
                    {
                    "use": "official"
                    <#if (component.getSection().getId().getRoot())?? >
                        ,
                        "system": "urn:oid:${component.getSection().getId().getRoot()!""}"
                    </#if>
                    <#if (component.getSection().getId().getExtension())?? >
                        ,
                        "value": "${component.getSection().getId().getExtension()!""}"
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
                "reference": "Patient/${patientUuid}",
                "display": "Maria Dimou"
                }
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