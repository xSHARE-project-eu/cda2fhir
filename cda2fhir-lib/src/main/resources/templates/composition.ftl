<#escape x as x?json_string>
    {
    "resource": {
    "resourceType": "Composition",
    "id": "${uuid.generate()}",
    "type": {
    "coding": [
    {
    "system": "http://loinc.org",
    "code": "60591-5",
    "display": "Patient Summary Document"
    }
    ]
    },
    "title": "${(cda.getTitle().getText())!''}",
    "date": "${(cda.getEffectiveTime().getValue()?date("yyyyMMddHHmmss")?string("yyyy-MM-dd'T'HH:mm:ssXXX"))!''}",
    "section": [
    <#list cda.getComponent().getStructuredBody().getComponents() as component>
        {
        <#if (component.getSection().getTitle().getText())??>
            "title": "${(component.getSection().getTitle().getText())}",
        </#if>
        "code": {
        "coding": [
        {
        "system": "${(component.getSection().getCode().getCodeSystem())!'Unknown System'}"
        <#if (component.getSection().getCode().getCode())??>
            ,
            "code": "${(component.getSection().getCode().getCode())}"
        </#if>
        <#if (component.getSection().getCode().getDisplayName())??>
            ,
            "display": "${(component.getSection().getCode().getDisplayName())}"
        </#if>
        }
        ]
        },
        "mode": "snapshot",
        "entry": [
        <#if component.getSection()?if_exists.getCode()?if_exists.getCode() == "29762-2">

            <#list component.getSection()?if_exists.getEntries() as entry>
                {
                "reference": "Observation/${uuid.generate()}"
                <#if (entry.getObservation().getCode().getDisplayName())?? >
                    ,
                    "display": "${(entry.getObservation().getCode().getDisplayName())}"
                </#if>
                }<#if entry_has_next>,</#if>
            </#list>

        <#elseif component.getSection()?if_exists.getCode()?if_exists.getCode() == "8716-3">

            <#list component.getSection()?if_exists.getEntries() as entry>
                <#list entry.getOrganizer()?if_exists.getComponents() as component>
                    {
                    "reference": "Observation/${uuid.generate()}"
                    <#if (component.getObservation().getCode().getDisplayName())?? >
                        ,
                        "display": "${component.getObservation().getCode().getDisplayName()}"
                    </#if>
                    }<#if component_has_next>,</#if>
                </#list><#if entry_has_next>,</#if>
            </#list>

        <#elseif component.getSection()?if_exists.getCode()?if_exists.getCode() == "10160-0">

            <#list component.getSection()?if_exists.getEntries() as entry>
                {
                "reference": "MedicationStatement/${uuid.generate()}"
                <#if (entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getDisplayName())?? >
                    ,
                    "display": "${(entry.getSubstanceAdministration().getConsumable().getManufacturedProduct().getManufacturedMaterial().getCode().getDisplayName())}"
                </#if>
                }<#if entry_has_next>,</#if>
            </#list>

        <#elseif component.getSection()?if_exists.getCode()?if_exists.getCode() == "48765-2">

            <#list component.getSection()?if_exists.getEntries() as entry>
                <#list entry.getAct()?if_exists.getEntryRelationships()?if_exists as relationship>
                    {
                    "reference": "AllergyIntolerance/${uuid.generate()}"
                    <#if (relationship.getObservation().getCode().getDisplayName())?? >
                        ,
                        "display": "${relationship.getObservation().getCode().getDisplayName()}"
                    </#if>
                    }<#if relationship_has_next>,</#if>
                </#list><#if entry_has_next>,</#if>
            </#list>

        <#elseif component.getSection()?if_exists.getCode()?if_exists.getCode() == "11450-4">

            <#list component.getSection()?if_exists.getEntries() as entry>
                {
                "reference": "Condition/${uuid.generate()}"
                <#if (entry.getAct().getEntryRelationships()[0].getObservation().getValues()[0].getDisplayName())?? >
                    ,
                    "display": "${entry.getAct().getEntryRelationships()[0].getObservation().getValues()[0].getDisplayName()}"
                </#if>
                }<#if entry_has_next>,</#if>
            </#list>

        <#elseif component.getSection()?if_exists.getCode()?if_exists.getCode() == "46264-8">

            <#list component.getSection()?if_exists.getEntries() as entry>
                {
                "reference": "Device/${uuid.generate()}}"
                <#if (entry.getSupply().getText().getReference().getValue())?? >
                    ,
                    "display": "${entry.getSupply().getText().getReference().getValue()}"
                </#if>
                }<#if entry_has_next>,</#if>
            </#list>
        <#elseif component.getSection()?if_exists.getCode()?if_exists.getCode() == "47519-4">

            <#list component.getSection()?if_exists.getEntries() as entry>
                {
                "reference": "Procedure/${uuid.generate()}"
                <#if (entry.getProcedure().getCode().getDisplayName())?? >
                    ,
                    "display": "${entry.getProcedure().getCode().getDisplayName()}"
                </#if>
                }<#if entry_has_next>,</#if>
            </#list>
        </#if>
        ]
        }<#if component_has_next>,</#if>
    </#list>
    ]
    },
    "request": {
    "method": "POST",
    "url": "Composition"
    }
    }
    <#global gcomma = true>
</#escape>