<#escape x as x?json_string>
    {
    "resourceType": "Bundle",
    "type": "transaction",
    "entry": [
    <#global gcomma = false>

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "composition.ftl">

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

    <#if gcomma>,</#if>
    <#global gcomma=false>
    <#include "practitioner.ftl">
    ]
    }
</#escape>
