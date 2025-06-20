    <#assign comma = false>

    <#list cda.getComponent().getStructuredBody().getComponents() as component>
        <#if component.getSection()?has_content && component.getSection().getCode().getCode() == "11450-4">
            <#list component.getSection().getEntries() as entry>
                <#if entry.getAct()?has_content>
                    <#list entry.getAct().getEntryRelationships() as relationship>
                        <#if relationship.getObservation()?has_content>
                            <#if comma>,</#if>
                            <#assign comma = true>
                            <#assign conditionuuid= uuid.generate()>


                            {
                            "fullUrl": "urn:uuid:${conditionuuid}",
                            "resource": {
                            "resourceType": "Condition",
                            "id": "${conditionuuid}",
                            <#if relationship.getObservation().getIds()??>
                                "identifier": [
                                {
                                "use": "official",
                                <#if (relationship.getObservation().getIds())?? && (relationship.getObservation().getIds()[0].getExtension())??>
                                    "value": "${(relationship.getObservation().getIds()[0].getExtension())!''}",
                                    "system": "urn:oid:${(relationship.getObservation().getIds()[0].getRoot())!''}"
                                <#else>
                                    "system":"urn:ietf:rfc:3986",
                                    "value":"urn:oid:${(relationship.getObservation().getIds()[0].getRoot())!''}"
                                </#if>
                                }
                                ],
                            </#if>
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
                                <#if relationship.getObservation().getValues()[0].getCodeSystem() == "2.16.840.1.113883.6.1">
                                    <#assign system = "http://loinc.org">
                                <#elseif relationship.getObservation().getValues()[0].getCodeSystem() == "1.3.6.1.4.1.12559.11.10.1.3.1.44.2">
                                    <#assign system = "http://hl7.org/fhir/sid/icd-10">
                                <#else>
                                    <#assign system = "http://snomed.info/sct">
                                </#if>
                                "system": "${system}"
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
                            "reference": "urn:uuid:${patientUuid}",
                            "display": "Patient"
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
