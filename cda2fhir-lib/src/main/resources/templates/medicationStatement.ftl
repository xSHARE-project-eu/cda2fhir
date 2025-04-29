<#escape x as x?json_string>
    <#assign comma = false>
    <#list cda.getComponent().getStructuredBody().getComponents() as component>
        <#if component.getSection()?has_content && component.getSection().getCode().getCode() == "10160-0">
            <#list component.getSection().getEntries() as entry>
                <#if entry.getSubstanceAdministration()?has_content>
                    <#if comma>,</#if>
                    <#assign comma = true>
                    {
                    "resource": {
                    "resourceType": "MedicationStatement",
                    "id": "${uuid.generate()}",
                    "identifier": [
                    {
                    "use": "official",
                    "system": "urn:oid:${(entry.getSubstanceAdministration().getIds()[0].getExtension())!''}",
                    "value": "${(entry.getSubstanceAdministration().getIds()[0].getRoot())!''}"
                    }
                    ],
                    "status": "${(entry.getSubstanceAdministration().getStatusCode().getCode())!"active"}",
                    "medicationReference": {
                    "reference": "Medication/${uuid.generate()}"
                    <#if (entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getDisplayName())??>
                        ,
                        "display": "${entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getDisplayName()!''}"
                    </#if>
                    },
                    "subject": {
                    "reference": "Patient/${patientUuid}",
                    "display": "ΜΑΡΙΑ ΔΗΜΟΥ"
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
                            "period": "${(entry.getSubstanceAdministration().getEffectiveTimes()[1].getPeriod().getValue())!""}"
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
                            "value": "${(entry.getSubstanceAdministration().getDoseQuantity().getValue())!""}",
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
</#escape>
