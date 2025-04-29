<#escape x as x?json_string>
    <#assign comma = false>

    <#list cda.getComponent().getStructuredBody().getComponents() as component>
        <#if component.getSection()?has_content && component.getSection().getCode().getCode() == "11450-4">
            <#list component.getSection().getEntries() as entry>
                <#if entry.getAct()?has_content>
                    <#list entry.getAct().getEntryRelationships() as relationship>
                        <#if relationship.getObservation()?has_content>
                            <#if comma>,</#if>
                            <#assign comma = true>

                            {
                            "resource": {
                            "resourceType": "Condition",
                            "id": "${uuid.generate()}",
                            "identifier": [
                            {
                            "use": "official",
                            <#if (relationship.getObservation().getIds()[0].getExtension())?? >
                                "system": "urn:oid:${(relationship.getObservation().getIds()[0].getExtension())!''}",
                            </#if>
                            "value": "${(relationship.getObservation().getIds()[0].getRoot())!''}"
                            }
                            ],
                            "clinicalStatus": {
                            "coding": [
                            {
                            "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
                            "code": "active",
                            "display": "Active"
                            }
                            ]
                            },
                            "verificationStatus": {
                            "coding": [
                            {
                            "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
                            "code": "confirmed",
                            "display": "Confirmed"
                            }
                            ]
                            },
                            "category": [
                            {
                            "coding": [
                            {
                            "system": "http://terminology.hl7.org/CodeSystem/condition-category",
                            "code": "problem-list-item",
                            "display": "Problem List Item"
                            }
                            ]
                            }
                            ],
                            "code": {
                            "coding": [
                            {
                            <#if (relationship.getObservation().getValues()[0].getCodeSystem())?? >
                                "system": "${relationship.getObservation().getValues()[0].getCodeSystem()!''}"
                            </#if>
                            <#if (relationship.getObservation().getValues()[0].getCode())?? >
                                ,
                                "code": "${relationship.getObservation().getValues()[0].getCode()!''}"
                            </#if>
                            <#if (relationship.getObservation().getValues()[0].getDisplayName())?? >
                                ,
                                "display": "${relationship.getObservation().getValues()[0].getDisplayName()!''}"
                            </#if>
                            }
                            ]
                            },
                            "subject": {
                            "reference": "Patient/${patientUuid}",
                            "display": "Maria Dimou"
                            }
                            },
                            "request": {
                            "method": "POST",
                            "url": "Condition",
                            "ifNoneExist": "identifier=${(relationship.getObservation().getIds()[0].getRoot())!''}|${(relationship.getObservation().getIds()[0].getExtension())!''}"
                            }
                            }
                            <#global gcomma = true>
                        </#if>
                    </#list>
                </#if>
            </#list>
        </#if>
    </#list>
</#escape>
