<#escape x as x?jsonString>
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
                                {
                                "resource": {
                                "resourceType": "AllergyIntolerance",
                                "id": "${uuid.generate()}",
                                "identifier": [
                                {
                                "use": "official",
                                "system": "urn:oid:${(observationAct.getIds()[0].getExtension())!""}",
                                "value": "${(observationAct.getIds()[0].getRoot())!""}"
                                }
                                ]
                                <#if (observationAct.getStatusCode().getCode())?? >
                                    ,
                                    "clinicalStatus": {
                                    "coding": [
                                    {
                                    "system": "http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical",
                                    "code": "${observationAct.getStatusCode().getCode()}",
                                    "display": "${observationAct.getStatusCode().getCode()}"
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
                                "reference": "Patient/${patientUuid}",
                                "display": "ΜΑΡΙΑ ΔΗΜΟΥ"
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
                                <#if (observationEntry.getObservation().getValues()[0])??>
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
</#escape>
