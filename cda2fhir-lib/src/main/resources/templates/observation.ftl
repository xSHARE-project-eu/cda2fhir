    <#assign comma = false>

    <#list cda.getComponent().getStructuredBody().getComponents() as component>
        <#if component.getSection()?hasContent && (component.getSection().getEntries()?size > 0)>
            <#list component.getSection().getEntries() as entry>

                <#if entry.getObservation()?hasContent>
                    <#if comma>,</#if>
                    <#assign comma = true>
                    <#assign observationuuid=uuid.generate()>
                    {
                    "fullUrl": "urn:uuid:${observationuuid}",
                    "resource": {
                    "resourceType": "Observation",
                    "id": "${observationuuid}",
                    "status": "final",
                    "category" : [
                    {
                    "coding" : [
                    {
                    "system" : "http://terminology.hl7.org/CodeSystem/observation-category",
                    "code" : "laboratory"
                    }
                    ]
                    }
                    ],
                    "code": {
                    "coding": [
                    {
                    <#if entry.getObservation().getCode().getCodeSystem() == "2.16.840.1.113883.6.1">
                        <#assign system = "http://loinc.org">
                    <#else>
                        <#assign system = "http://snomed.info/sct">
                    </#if>
                    "system": "${system}",
                    "code": "${entry.getObservation().getCode().getCode()!''}",
                    "display": "${entry.getObservation().getCode().getDisplayName()!''}"
                    }
                    ]
                    },
                    "subject": {
                    "reference": "urn:uuid:${patientUuid}",
                    "display": "Patient"
                    }
                    <#if (entry.getObservation().getEffectiveTime().getLow().getValue())??>
                        <#if entry.getObservation().getEffectiveTime().getLow().getValue()?length == 8>
                            <#assign formattedDate = entry.getObservation().getEffectiveTime().getLow().getValue()?date("yyyyMMdd")?string("yyyy-MM-dd") />
                        <#elseIf entry.getObservation().getEffectiveTime().getLow().getValue()?length == 14>
                            <#assign formattedDate = entry.getObservation().getEffectiveTime().getLow().getValue()?date("yyyyMMddHHmmss")?string("yyyy-MM-dd'T'HH:mm:ssXXX") />
                        </#if>
                        <#if formattedDate??>
                            ,
                            "effectivePeriod": {
                            "start": "${formattedDate}"
                            }
                        </#if>
                    </#if>
                    <#if (entry.getObservation().getValues()[0].getValue())??>
                        ,
                        "valueQuantity": {
                        "value": ${(entry.getObservation().getValues()[0].getValue())!0.0},
                        "unit": "${(entry.getObservation().getValues()[0].getUnit())!"Check if it is mandatory"}"
                        }
                        },
                    <#else>
                        },
                    </#if>
                    "request": {
                    "method": "POST",
                    "url": "Observation",
                    "ifNoneExist": "identifier=${entry.getObservation().getIds()[0].getExtension()!''}|${entry.getObservation().getIds()[0].getRoot()!''}"
                    }
                    }
                    <#global gcomma = true>
                </#if>

                <#if entry.getOrganizer()?hasContent>
                    <#list entry.getOrganizer().getComponents() as component>
                        <#if component.getObservation()?hasContent>
                            <#if comma>,</#if>
                            <#assign comma = true>
                            <#assign observationuuid=uuid.generate()>

                            {
                            "fullUrl": "urn:uuid:${observationuuid}",
                            "resource": {
                            "resourceType": "Observation",
                            "id": "${observationuuid}",
                            "status": "final",
                            "category" : [
                            {
                            "coding" : [
                            {
                            "system" : "http://terminology.hl7.org/CodeSystem/observation-category",
                            "code" : "vital-signs"
                            }
                            ]
                            }
                            ],
                            "code": {
                            "coding": [
                            {
                            <#if component.getObservation().getCode().getCodeSystem() == "2.16.840.1.113883.6.1">
                                <#assign system = "http://loinc.org">
                            <#else>
                                <#assign system = "http://snomed.info/sct">
                            </#if>
                            "system": "${system}",
                            "code": "${component.getObservation().getCode().getCode()!''}",
                            "display": "${component.getObservation().getCode().getDisplayName()!''}"
                            }
                            ]
                            },
                            "subject": {
                            "reference": "urn:uuid:${patientUuid}",
                            "display": "Patient"
                            }
                            <#if (component.getObservation().getEffectiveTime().getValue())??>
                                <#if component.getObservation().getEffectiveTime().getValue()?length == 8>
                                    <#assign formattedDate = component.getObservation().getEffectiveTime().getValue()?date("yyyyMMdd")?string("yyyy-MM-dd") />
                                <#elseIf component.getObservation().getEffectiveTime().getValue()?length == 14>
                                    <#assign formattedDate = component.getObservation().getEffectiveTime().getValue()?date("yyyyMMddHHmmss")?string("yyyy-MM-dd'T'HH:mm:ssXXX") />
                                </#if>
                                <#if formattedDate??>
                                    ,
                                    "effectivePeriod": {
                                    "start": "${formattedDate}"
                                    }
                                </#if>
                            </#if>
                            <#if (component.getObservation().getValues()[0].getValue())??>
                                ,
                                "valueQuantity": {
                                "value": ${(component.getObservation().getValues()[0].getValue())},
                                "unit": "${(component.getObservation().getValues()[0].getUnit())}"
                                }
                                },
                            <#else>
                                },
                            </#if>
                            "request": {
                            "method": "POST",
                            "url": "Observation",
                            "ifNoneExist": "identifier=${component.getObservation().getIds()[0].getExtension()!''}|${component.getObservation().getIds()[0].getRoot()!''}"
                            }
                            }
                            <#global gcomma = true>
                        </#if>
                    </#list>
                </#if>

            <#--        &lt;#&ndash; Handle Observations in Entry Relationships &ndash;&gt;-->
            <#--            <#if entry.getAct()?has_content && (entry.getAct().getEntryRelationships()?size > 0)>-->
            <#--                <#list entry.getAct().getEntryRelationships() as relationship>-->
            <#--                    <#if relationship.getObservation()?has_content>-->
            <#--                        <#if comma>,</#if>-->
            <#--                        <#assign comma = true>-->
            <#--                        {-->
            <#--                        "resource": {-->
            <#--                        "resourceType": "Observation",-->
            <#--                        "id": "${uuid.generate()}",-->
            <#--                        "status": "final",-->
            <#--                        "code": {-->
            <#--                        "coding": [-->
            <#--                        {-->
            <#--                        "system": "${relationship.getObservation().getCode().getCodeSystem()!''}",-->
            <#--                        "code": "${relationship.getObservation().getCode().getCode()!''}",-->
            <#--                        "display": "${relationship.getObservation().getCode().getDisplayName()!''}"-->
            <#--                        }-->
            <#--                        ]-->
            <#--                        },-->
            <#--                        "subject": {-->
            <#--                        "reference": "Patient/${patientUuid}",-->
            <#--                        "display": "Maria Dimou"-->
            <#--                        }-->
            <#--&lt;#&ndash;                        "effectivePeriod": {&ndash;&gt;-->
            <#--&lt;#&ndash;                        "start": "${relationship.getObservation().getEffectiveTime().getLow().getValue()}"&ndash;&gt;-->
            <#--&lt;#&ndash;                        }&ndash;&gt;-->
            <#--                        },-->
            <#--                        "request": {-->
            <#--                        "method": "POST",-->
            <#--                        "url": "Observation",-->
            <#--                        "ifNoneExist": "identifier=${relationship.getObservation().getIds()[0].getRoot()!''}|${relationship.getObservation().getIds()[0].getExtension()!''}"-->
            <#--                        }-->
            <#--                        }-->
            <#--                    </#if>-->
            <#--                </#list>-->
            <#--            </#if>-->
            </#list>
        </#if>
    </#list>
