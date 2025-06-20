<#escape x as x?json_string>
    <#assign provenanceUuid=uuid.generate()>
    {
    "fullUrl": "urn:uuid:${provenanceUuid}",
    "resource": {
    "resourceType": "Provenance",
    "id": "${provenanceUuid}",
    "target": [
    <#if fhirBundle.getEntry()?has_content>
        <#list fhirBundle.getEntry() as entry>
            <#assign resource = entry.getResource()>
            <#if resource.getResourceType().getPath() == 'device'>
                <#assign resourceDevice = entry.getResource()>
            </#if>
            <#if resource.getResourceType().getPath() == 'documentreference'>
                <#assign resourceDocRef = entry.getResource()>
            </#if>
            {
            "reference": "urn:uuid:${resource.getIdPart()}",
            "display": "${resource.getResourceType()}"
            }<#if entry_has_next>,</#if>
        </#list>
    </#if>
    ]
    },
    "recorded" : "${.now?string("yyyy-MM-dd")}",
    "agent" : [ {
    "type" : {
    "coding" : [ {
    "id" : "${(resourceDevice.getId())!""}",
    "system" : "http://terminology.hl7.org/CodeSystem/provenance-participant-type",
    "code" : "assembler",
    "display" : "Assembler"
    } ]
    },
    "role" : [ {
    "coding" : [ {
    "id" : "${(resourceDevice.getId())!""}",
    "system" : "http://hl7.org/fhir/provenance-participant-role",
    "code" : "assembler",
    "display" : "Assembler"
    } ]
    } ],
    "who" : {
    "reference" : "${(resourceDevice.getId())!""}"
    }
    } ],
    "entity" : [ {
    "role" : "source",
    "what" : {
    "reference" : "${(resourceDocRef.getId())!"No Document Reference"}"
<#--    "display" : "${documentReferenceTitle}"-->
    }
    } ],
    "request" : {
    "method" : "POST",
    "url" : "Provenance"
    }
    }
</#escape>