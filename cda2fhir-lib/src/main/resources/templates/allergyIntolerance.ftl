    <#assign comma = false>
    [
    <#list cda.getComponent().getStructuredBody().getComponents() as component>

        <#if component.getSection()?hasContent && component.getSection().getCode().getCode() == "48765-2">
            <#list component.getSection().getEntries() as entry>
                <#list entry.getAct().getEntryRelationships() as entryRelationship>

                    <#if entryRelationship.getObservation()?hasContent>
                        <#assign observationAct = entryRelationship.getObservation()>
                        <#list observationAct.getEntryRelationships() as observationEntry>
                            <#if observationEntry.getObservation()?hasContent>
                                <#if comma>,</#if>
                                <#assign comma = true>
                                <#assign allergyuuid= uuid.generate()>

                                {
                                "fullUrl": "urn:uuid:${allergyuuid}",
                                "resource": {
                                "resourceType": "AllergyIntolerance",
                                "id": "${allergyuuid}",
                                "identifier": [
                                {
                                "use": "official",
                                <#if observationAct.getIds()[0].getExtension()??>
                                    "value": "${(observationAct.getIds()[0].getExtension())!''}",
                                    "system": "urn:oid:${(observationAct.getIds()[0].getRoot())!''}"
                                <#else>
                                    "system":"urn:ietf:rfc:3986",
                                    "value":"urn:oid:${(observationAct.getIds()[0].getRoot())!''}"
                                </#if>
                                }
                                ]
                                <#if (observationAct.getStatusCode().getCode())?? >
                                    <#if observationAct.getStatusCode().getCode() == "completed">
                                        <#assign mappedCode = "resolved">
                                        <#assign mappedDisplay = "Resolved">
                                    <#elseIf observationAct.getStatusCode().getCode() == "active">
                                        <#assign mappedCode = "active">
                                        <#assign mappedDisplay = "Active">
                                    <#else>
                                        <#assign mappedCode = observationAct.getStatusCode().getCode()>
                                        <#assign mappedDisplay = observationAct.getStatusCode().getCode()>
                                    </#if>
                                    ,
                                    "clinicalStatus": {
                                    "coding": [
                                    {
                                    "system": "http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical",
                                    "code": "${mappedCode}",
                                    "display": "${mappedDisplay}"
                                    }
                                    ]
                                    },
                                <#else>
                                    ,
                                </#if>
                                "verificationStatus": {
                                "coding": [
                                {
                                "system": "http://terminology.hl7.org/CodeSystem/allergyintolerance-verification",
                                "code": "confirmed",
                                "display": "confirmed"
                                }
                                ]
                                },
                                "patient": {
                                "reference": "urn:uuid:${patientUuid}",
                                "display": "Patient"
                                },
                                <#if (observationAct.getEffectiveTime().getLow().getValue())??>
                                    <#if observationAct.getEffectiveTime().getLow().getValue()?length == 8>
                                        <#assign formattedDate = observationAct.getEffectiveTime().getLow().getValue()?date("yyyyMMdd")?string("yyyy-MM-dd") />
                                    <#elseIf observationAct.getEffectiveTime().getLow().getValue()?length == 14>
                                        <#assign formattedDate = observationAct.getEffectiveTime().getLow().getValue()?date("yyyyMMddHHmmss")?string("yyyy-MM-dd'T'HH:mm:ssXXX") />
                                    </#if>
                                    <#if formattedDate??>
                                        "recordedDate": "${formattedDate}",
                                    </#if>
                                </#if>
                                "reaction": [
                                {
                                <#if (observationAct.getParticipants()[0].getParticipantRole().getPlayingEntity().getCode())??>
                                    "substance": {
                                    "coding": [
                                    {
                                    "system": "http://snomed.info/sct"
                                    <#if (observationAct.getParticipants()[0].getParticipantRole().getPlayingEntity().getCode().getCode())??>
                                        ,
                                        "code": "${(observationAct.getParticipants()[0].getParticipantRole().getPlayingEntity().getCode().getCode())}"
                                    </#if>
                                    <#if (observationAct.getParticipants()[0].getParticipantRole().getPlayingEntity().getCode().getDisplayName())??>
                                        ,
                                        "display": "${(observationAct.getParticipants()[0].getParticipantRole().getPlayingEntity().getCode().getDisplayName())!}"
                                    </#if>
                                    }
                                    ],
                                    "text": "${(observationAct.getParticipants()[0].getParticipantRole().getPlayingEntity().getCode().getOriginalText().getReference().getValue())!"No text"}"
                                    },
                                </#if>
                                <#if (observationEntry.getObservation().getValues()[0])?? && (observationEntry.getObservation().getValues()[0].getCode())??>
                                    "manifestation": [
                                    {
                                    "coding": [
                                    {
                                    "system": "http://snomed.info/sct"
                                    <#if (observationEntry.getObservation().getValues()[0].getCode())?? >
                                        ,
                                        "code": "${(observationEntry.getObservation().getValues()[0].getCode())}"
                                    </#if>
                                    <#if (observationEntry.getObservation().getValues()[0].getDisplayName())?? >
                                        ,
                                        "display": "${(observationEntry.getObservation().getValues()[0].getDisplayName())}"
                                    </#if>
                                    }
                                    ],
                                    "text": "${(observationEntry.getObservation().getText().getReference().getValue())!"No text"}"
                                    }
                                    ]
                                    }
                                    ]
                                </#if>
                                },
                                "request": {
                                "method": "POST",
                                "url": "AllergyIntolerance",
                                "ifNoneExist": "identifier=${(observationAct.getIds()[0].getRoot())!""}|${(observationEntry.getObservation().getIds()[0].getExtension())!""}"
                                }
                                }
                            </#if>
                        </#list>
                    </#if>
                </#list>
            </#list>
        </#if>
    </#list>
    ]
    <#global gcomma = true>
