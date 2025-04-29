<#--<#list input.component.structuredBody.component as section>-->
<#--    <#if section.section.title == "Medication Summary">-->
<#--        {-->
<#--        "resource": {-->
<#--        "resourceType": "MedicationStatement",-->
<#--        "id": "${UUID.randomUUID()}",-->
<#--        "status": "completed",-->
<#--        "medicationReference": {-->
<#--        "reference": "Medication/${UUID.randomUUID()}",-->
<#--        "display": "${section.section.entry.substanceAdministration.consumable.manufacturedProduct.manufacturedMaterial.name}"-->
<#--        },-->
<#--        "subject": {-->
<#--        "reference": "Patient/${UUID.randomUUID()}",-->
<#--        "display": "${input.recordTarget.patientRole.patient.name.family}, ${input.recordTarget.patientRole.patient.name.given}"-->
<#--        }-->
<#--        },-->
<#--        "request": {-->
<#--        "method": "POST",-->
<#--        "url": "MedicationStatement"-->
<#--        }-->
<#--        }-->
<#--        <#if section?has_next>,</#if>-->
<#--    </#if>-->
<#--</#list>-->