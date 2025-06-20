    <#assign comma = false>
    <#list cda.getComponent().getStructuredBody().getComponents() as component>
        <#if component.getSection()?has_content && component.getSection().getCode().getCode() == "10160-0">
            <#list component.getSection().getEntries() as entry>
                <#if entry.getSubstanceAdministration()?has_content>
                    <#if comma>,</#if>
                    <#assign comma = true>
                    <#assign medicationuuid=uuid.generate()>

                    {
                    "fullUrl": "urn:uuid:${medicationuuid}",
                    "resource": {
                    "resourceType": "MedicationStatement",
                    "id": "${medicationuuid}",
                    <#if (entry.getSubstanceAdministration().getIds())??>
                        "identifier": [
                        {
                        "use": "official",
                        <#if (entry.getSubstanceAdministration().getIds())?? && (entry.getSubstanceAdministration().getIds()[0].getExtension())??>
                            "value": "${(entry.getSubstanceAdministration().getIds()[0].getExtension())!''}",
                            "system": "urn:oid:${(entry.getSubstanceAdministration().getIds()[0].getRoot())!''}"
                        <#else>
                            "system":"urn:ietf:rfc:3986",
                            "value":"urn:oid:${(entry.getSubstanceAdministration().getIds()[0].getRoot())!''}"
                        </#if>
                        }
                        ],
                    </#if>
                    "status": "${(entry.getSubstanceAdministration().getStatusCode().getCode())!"active"}",
                    <#if entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getCodeSystem() == "2.16.840.1.113883.6.1">
                        <#assign system = "http://loinc.org">
                    <#elseif entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getCodeSystem() == "2.16.840.1.113883.6.96">
                        <#assign system = "http://snomed.info/sct">
                    <#else>
                        <#assign system = "http://www.nlm.nih.gov/research/umls/rxnorm">
                    </#if>
                    "medicationCodeableConcept": {
                    "coding": [
                    {
                    "system": "${system}",
                    "code": "${entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getCode()}",
                    "display": "${entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getDisplayName()}"
                    }
                    ]
                    },
                    "subject": {
                    "reference": "urn:uuid:${patientUuid}",
                    "display": "Patient"
                    },
                    <#if (entry.getSubstanceAdministration().getEffectiveTimes()[0].getValue())??>
                        "effectivePeriod": {
                        "start": "${(entry.getSubstanceAdministration().getEffectiveTimes()[0].getValue())!'Unknown Time , check if it is mandatory'}"
                        },
                    </#if>
                    "dosage": [
                    {
                    <#if (entry.getSubstanceAdministration().getEffectiveTimes()[1].getPeriod())??>
                        "timing": {
                        "repeat": {
                        <#if (entry.getSubstanceAdministration().getEffectiveTimes()[1].getPeriod().getValue()) ??>
                            "period": ${(entry.getSubstanceAdministration().getEffectiveTimes()[1].getPeriod().getValue())!""}
                        </#if>
                        <#if (entry.getSubstanceAdministration().getEffectiveTimes()[1].getPeriod().getUnit()) ??>
                            ,
                            "periodUnit": "${(entry.getSubstanceAdministration().getEffectiveTimes()[1].getPeriod().getUnit())!""}"
                        </#if>
                        }
                        }
                    </#if>
                    <#if (entry.getSubstanceAdministration().getDoseQuantity())?? >
                        ,
                        "doseAndRate": [
                        {
                        "doseQuantity": {
                        <#if (entry.getSubstanceAdministration().getDoseQuantity().getValue())?? >
                            "value": ${(entry.getSubstanceAdministration().getDoseQuantity().getValue())!""},
                        </#if>
                        <#if (entry.getSubstanceAdministration().getDoseQuantity().getUnit())?? >
                            "unit": "${(entry.getSubstanceAdministration().getDoseQuantity().getUnit())!""}",
                        <#else>
                            ,
                        </#if>
                        "system": "http://unitsofmeasure.org/ucum.html"
                        }
                        }
                        ]
                    </#if>
                    }
                    ]
                    },
                    "request": {
                    "method": "POST",
                    "url": "MedicationStatement",
                    "ifNoneExist": "identifier=${(entry.getSubstanceAdministration().getIds()[0].getExtension())!''}|${(entry.getSubstanceAdministration().getIds()[0].getRoot())!''}"
                    }
                    }
                </#if>
            </#list>
            <#global gcomma = true>
        </#if>
    </#list>
