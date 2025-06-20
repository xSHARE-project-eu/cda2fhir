{
"resourceType": "Bundle",
"type": "transaction",
"entry": [
<#list entries as entry>
    {
    <#if (entry.fullUrl)??>
        "fullUrl": "${entry.fullUrl}",
    </#if>
    "resource": ${entry.resource},
    "request": {
    "method": "POST",
    "url": "${entry.request.url}"
    }
    }<#if entry_has_next>,</#if>
</#list>,
${provenance}
]
}
