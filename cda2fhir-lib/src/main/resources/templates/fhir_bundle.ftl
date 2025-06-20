<#escape x as x?json_string>
    {
    "resourceType": "Bundle",
    "id": "${uuid.generate()}",
    "type": "transaction",
    "entry": [
    <#global gcomma = false>

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "patient.ftl">

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "organization.ftl">

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "observation.ftl">

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "condition.ftl">

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "procedure.ftl">

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "medicationStatement.ftl">

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "allergyIntolerance.ftl">

    <#if (cda.getLegalAuthenticator())?? && (cda.getLegalAuthenticator().getAssignedEntity())??>
        <#if gcomma>,</#if>
        <#global gcomma=false>
        <#include "practitioner.ftl">
    </#if>
    ]
    }
</#escape>
