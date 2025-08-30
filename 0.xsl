<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="msxsl exsl">  
<xsl:output
method="html"
indent="yes"
encoding="UTF-8"
doctype-system="about:legacy-compat"
/>
<!-- Main template -->
<xsl:template match="/">
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="color-scheme" content="light dark"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<link href="c.css" rel="stylesheet"/>
<xsl:variable name="page-title">
<xsl:call-template name="extract-yaml-title">
<xsl:with-param name="text" select="."/>
</xsl:call-template>
</xsl:variable>
<title>Skip - <xsl:value-of select="$page-title"/></title>
</head>
<body>
<a href="#post" class="skip_link" accesskey="3" tabindex="0">
<span title="Access Key 3">Skip to main content</span>
</a>
<nav id="site_nav">
<ul>
<li><a href="index.xml">Home</a></li>
<li><a href="log.xml">Log</a></li>
<li><a href="info.xml">Info</a></li>
</ul>
</nav>
<main>
<header>
<h1 id="top" class="h">
<xsl:call-template name="extract-yaml-title">
<xsl:with-param name="text" select="."/>
</xsl:call-template>
<a href="#top" accesskey="1">#</a>
</h1>
</header>
<xsl:variable name="content">
<xsl:call-template name="remove-yaml-frontmatter">
<xsl:with-param name="text" select="."/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="has-headers">
<xsl:call-template name="check-for-headers">
<xsl:with-param name="text" select="$content"/>
</xsl:call-template>
</xsl:variable>
<!-- Lead content -->
<xsl:if test="$has-headers = 'true'">
<xsl:variable name="lead-content">
<xsl:call-template name="extract-lead-content">
<xsl:with-param name="text" select="$content"/>
</xsl:call-template>
</xsl:variable>
<xsl:if test="normalize-space($lead-content) != ''">
<section class="lead">
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$lead-content"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</section>
</xsl:if>
</xsl:if>
<!-- TOC -->
<xsl:if test="$has-headers = 'true'">
<details id="map_holder">
<summary tabindex="0" accesskey="2"><span>Map</span></summary>
<div id="map">
<ul>
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$content"/>
</xsl:call-template>
</ul>
</div>
</details>
</xsl:if>
<!-- Main content -->
<article id="post" class="no_outline" tabindex="-1" accesskey="3">
<xsl:choose>
<xsl:when test="$has-headers = 'true'">
<xsl:variable name="content-from-first-header">
<xsl:call-template name="extract-content-from-first-header">
<xsl:with-param name="text" select="$content"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$content-from-first-header"/>
<xsl:with-param name="enable-sections" select="true()"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$content"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</article>
</main>
<footer>
<a id="to_top" href="#top">Top</a>
<!--Notice-->
<span 
title="Markdown to HTML Processor .xsl (XSLT 1.0) sheet. By and copyright Greg Abbott 2025. Version 1: 2025-08-26. Version: 2025-08-28"
>
&#169; 2025
<a
href="https://gregabbott.pages.dev/"
>Greg Abbott</a>. 
</span>
</footer>
</body>
</html>
</xsl:template>
<!-- Unified content processing entry point -->
<xsl:template name="process-content">
<xsl:param name="text"/>
<xsl:param name="enable-sections" select="false()"/>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$text"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="0"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:template>
<!-- Main processing template - preserves original structure -->
<xsl:template name="process-lines">
<xsl:param name="remaining"/>
<xsl:param name="in-code-block"/>
<xsl:param name="in-blockquote"/>
<xsl:param name="in-list"/>
<xsl:param name="list-level"/>
<xsl:param name="list-type"/>
<xsl:param name="section-level"/>
<xsl:param name="paragraph-accumulator"/>
<xsl:param name="enable-sections" select="false()"/>
<xsl:if test="string-length($remaining) > 0">
<xsl:variable name="line">
<xsl:choose>
<xsl:when test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-before($remaining, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$remaining"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="rest">
<xsl:if test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-after($remaining, '&#10;')"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<!-- Code block handling -->
<xsl:when test="starts-with($line, '```')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:call-template name="close-lists">
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
<xsl:choose>
<!-- Starting blockquote -->
<xsl:when test="starts-with($line, '```blockquote') and $in-blockquote = false()">
<xsl:text disable-output-escaping="yes">&lt;blockquote&gt;</xsl:text>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="true()"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Starting table block -->
<xsl:when test="starts-with($line, '```table') and $in-code-block = false()">
<xsl:variable name="table-content">
<xsl:call-template name="collect-until-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:variable>
<table border="1" cellpadding="0" cellspacing="0">
<xsl:call-template name="parse-table-content">
<xsl:with-param name="content" select="$table-content"/>
</xsl:call-template>
</table>
<xsl:variable name="remaining-after-table">
<xsl:call-template name="skip-until-after-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$remaining-after-table"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Ending blockquote -->
<xsl:when test="$line = '```' and $in-blockquote = true()">
<xsl:text disable-output-escaping="yes">&lt;/blockquote&gt;</xsl:text>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Regular code block toggle -->
<xsl:when test="$in-code-block = true()">
<xsl:text disable-output-escaping="yes">&lt;/code&gt;&lt;/pre&gt;</xsl:text>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text disable-output-escaping="yes">&lt;pre&gt;&lt;code&gt;</xsl:text>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="true()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Inside code block -->
<xsl:when test="$in-code-block = true()">
<xsl:value-of select="$line"/>
<xsl:if test="string-length($rest) > 0">
<xsl:text>&#10;</xsl:text>
</xsl:if>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="true()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="list-level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="$paragraph-accumulator"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Empty line -->
<xsl:when test="normalize-space($line) = ''">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:call-template name="close-lists">
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Headers -->
<xsl:when test="starts-with($line, '#') and $in-code-block = false()">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:variable name="heading-level">
<xsl:call-template name="count-heading-level">
<xsl:with-param name="line" select="$line"/>
</xsl:call-template>
</xsl:variable>
<!-- Section management (only outside blockquotes and when enabled) -->
<xsl:variable name="new-section-level">
<xsl:choose>
<xsl:when test="$enable-sections and $in-blockquote = false()">
<xsl:call-template name="close-lists">
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
<xsl:if test="$heading-level &lt;= $section-level and $section-level > 0">
<xsl:call-template name="close-sections">
<xsl:with-param name="from-level" select="$section-level"/>
<xsl:with-param name="to-level" select="$heading-level - 1"/>
</xsl:call-template>
</xsl:if>
<xsl:text disable-output-escaping="yes">&lt;section&gt;</xsl:text>
<xsl:value-of select="$heading-level"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$section-level"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!-- Process heading -->
<xsl:call-template name="process-heading">
<xsl:with-param name="line" select="$line"/>
<xsl:with-param name="shift-level" select="$enable-sections and $in-blockquote = false()"/>
</xsl:call-template>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$new-section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Task lists -->
<xsl:when test="starts-with($line, '- [ ]') or starts-with($line, '- [x]') or starts-with($line, '- [X]')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:variable name="current-level" select="1"/>
<xsl:call-template name="manage-list-nesting">
<xsl:with-param name="current-level" select="$current-level"/>
<xsl:with-param name="list-level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
<xsl:with-param name="new-type" select="'ul'"/>
<xsl:with-param name="in-list" select="$in-list"/>
</xsl:call-template>
<li class="task-list-item">
<input type="checkbox" name="_todo" disabled="disabled">
<xsl:if test="contains($line, '[x]') or contains($line, '[X]')">
<xsl:attribute name="checked">checked</xsl:attribute>
</xsl:if>
</input>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($line, '] ')"/>
</xsl:call-template>
</li>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="true()"/>
<xsl:with-param name="list-level" select="$current-level"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Ordered list items -->
<xsl:when test="substring($line, 1, 1) &gt;= '0' and substring($line, 1, 1) &lt;= '9' and contains(substring($line, 1, 5), '. ')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:variable name="current-level" select="1"/>
<xsl:variable name="item-text" select="normalize-space(substring-after($line, '. '))"/>
<xsl:call-template name="manage-list-nesting">
<xsl:with-param name="current-level" select="$current-level"/>
<xsl:with-param name="list-level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
<xsl:with-param name="new-type" select="'ol'"/>
<xsl:with-param name="in-list" select="$in-list"/>
</xsl:call-template>
<li>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$item-text"/>
</xsl:call-template>
</li>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="true()"/>
<xsl:with-param name="list-level" select="$current-level"/>
<xsl:with-param name="list-type" select="'ol'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Multi-level unordered list handling -->
<xsl:when test="starts-with($line, '-') and substring($line, string-length(substring-before(concat($line, ' '), ' ')) + 1, 1) = ' '">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:variable name="current-level">
<xsl:call-template name="count-list-level">
<xsl:with-param name="line" select="$line"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="item-text">
<xsl:call-template name="get-list-item-text">
<xsl:with-param name="line" select="$line"/>
<xsl:with-param name="level" select="$current-level"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="manage-list-nesting">
<xsl:with-param name="current-level" select="$current-level"/>
<xsl:with-param name="list-level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
<xsl:with-param name="new-type" select="'ul'"/>
<xsl:with-param name="in-list" select="$in-list"/>
</xsl:call-template>
<li>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$item-text"/>
</xsl:call-template>
</li>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="true()"/>
<xsl:with-param name="list-level" select="$current-level"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Horizontal rule -->
<xsl:when test="$line = '---' or $line = '***' or $line = '___'">
<xsl:call-template name="close-lists">
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
<hr/>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Image-only line -->
<xsl:when test="starts-with(normalize-space($line), '![') and substring(normalize-space($line), string-length(normalize-space($line))) = ')' and contains($line, '](')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:call-template name="close-lists">
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space($line)"/>
</xsl:call-template>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="false()"/>
<xsl:with-param name="list-level" select="0"/>
<xsl:with-param name="list-type" select="'ul'"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
<!-- Regular content line -->
<xsl:otherwise>
<xsl:variable name="new-accumulator">
<xsl:choose>
<xsl:when test="normalize-space($paragraph-accumulator) = ''">
<xsl:value-of select="normalize-space($line)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat($paragraph-accumulator, ' ', normalize-space($line))"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="list-level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
<xsl:with-param name="section-level" select="$section-level"/>
<xsl:with-param name="paragraph-accumulator" select="$new-accumulator"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
<!-- End of content cleanup -->
<xsl:if test="string-length($remaining) = 0">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-accumulator"/>
</xsl:call-template>
<xsl:call-template name="close-lists">
<xsl:with-param name="in-list" select="$in-list"/>
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
<xsl:if test="$in-blockquote = true()">
<xsl:text disable-output-escaping="yes">&lt;/blockquote&gt;</xsl:text>
</xsl:if>
<xsl:if test="$section-level > 0">
<xsl:call-template name="close-sections">
<xsl:with-param name="from-level" select="$section-level"/>
<xsl:with-param name="to-level" select="0"/>
</xsl:call-template>
</xsl:if>
</xsl:if>
</xsl:template>
<!-- Helper templates -->
<xsl:template name="flush-paragraph">
<xsl:param name="paragraph"/>
<xsl:if test="normalize-space($paragraph) != ''">
<p>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$paragraph"/>
</xsl:call-template>
</p>
</xsl:if>
</xsl:template>
<xsl:template name="close-lists">
<xsl:param name="in-list"/>
<xsl:param name="level"/>
<xsl:param name="list-type"/>
<xsl:if test="$in-list = true()">
<xsl:call-template name="close-lists-recursive">
<xsl:with-param name="level" select="$level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="manage-list-nesting">
<xsl:param name="current-level"/>
<xsl:param name="list-level"/>
<xsl:param name="list-type"/>
<xsl:param name="new-type"/>
<xsl:param name="in-list"/>
<xsl:choose>
<xsl:when test="$current-level > $list-level or $new-type != $list-type">
<xsl:if test="$in-list = true() and $new-type != $list-type">
<xsl:call-template name="close-lists-recursive">
<xsl:with-param name="level" select="$list-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:if>
<xsl:call-template name="open-lists">
<xsl:with-param name="from" select="$list-level + 1"/>
<xsl:with-param name="to" select="$current-level"/>
<xsl:with-param name="list-type" select="$new-type"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="$current-level &lt; $list-level">
<xsl:call-template name="close-lists-to-level">
<xsl:with-param name="from" select="$list-level"/>
<xsl:with-param name="to" select="$current-level"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:when>
</xsl:choose>
</xsl:template>
<!-- Unified heading processing -->
<xsl:template name="process-heading">
<xsl:param name="line"/>
<xsl:param name="shift-level" select="false()"/>
<xsl:variable name="heading-text" select="normalize-space(translate($line, '#', ''))"/>
<xsl:variable name="heading-id">
<xsl:call-template name="generate-heading-id">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test="starts-with($line, '######')">
<h6 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h6>
</xsl:when>
<xsl:when test="starts-with($line, '#####')">
<xsl:choose>
<xsl:when test="$shift-level">
<h6 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h6>
</xsl:when>
<xsl:otherwise>
<h5 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h5>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="starts-with($line, '####')">
<xsl:choose>
<xsl:when test="$shift-level">
<h5 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h5>
</xsl:when>
<xsl:otherwise>
<h4 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h4>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="starts-with($line, '###')">
<xsl:choose>
<xsl:when test="$shift-level">
<h4 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h4>
</xsl:when>
<xsl:otherwise>
<h3 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h3>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="starts-with($line, '##')">
<xsl:choose>
<xsl:when test="$shift-level">
<h3 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h3>
</xsl:when>
<xsl:otherwise>
<h2 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h2>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="starts-with($line, '#')">
<xsl:choose>
<xsl:when test="$shift-level">
<h2 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h2>
</xsl:when>
<xsl:otherwise>
<h1 class="h" id="{$heading-id}">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
<a href="#{$heading-id}" tabindex="0">#</a>
</h1>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
</xsl:choose>
</xsl:template>
<!-- Content extraction templates -->
<xsl:template name="extract-lead-content">
<xsl:param name="text"/>
<xsl:call-template name="extract-lead-content-recursive">
<xsl:with-param name="remaining" select="$text"/>
<xsl:with-param name="accumulator" select="''"/>
</xsl:call-template>
</xsl:template>
<xsl:template name="extract-lead-content-recursive">
<xsl:param name="remaining"/>
<xsl:param name="accumulator"/>
<xsl:if test="string-length($remaining) > 0">
<xsl:variable name="line">
<xsl:choose>
<xsl:when test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-before($remaining, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$remaining"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="rest">
<xsl:if test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-after($remaining, '&#10;')"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<xsl:when test="starts-with($line, '#')">
<xsl:value-of select="$accumulator"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="new-accumulator">
<xsl:choose>
<xsl:when test="$accumulator = ''">
<xsl:value-of select="concat($line, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat($accumulator, $line, '&#10;')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="extract-lead-content-recursive">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="accumulator" select="$new-accumulator"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>
<xsl:template name="extract-content-from-first-header">
<xsl:param name="text"/>
<xsl:call-template name="skip-to-first-header">
<xsl:with-param name="remaining" select="$text"/>
</xsl:call-template>
</xsl:template>
<xsl:template name="skip-to-first-header">
<xsl:param name="remaining"/>
<xsl:if test="string-length($remaining) > 0">
<xsl:variable name="line">
<xsl:choose>
<xsl:when test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-before($remaining, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$remaining"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="rest">
<xsl:if test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-after($remaining, '&#10;')"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<xsl:when test="starts-with($line, '#')">
<xsl:value-of select="$remaining"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="skip-to-first-header">
<xsl:with-param name="remaining" select="$rest"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>
<!-- YAML processing templates -->
<xsl:template name="extract-yaml-title">
<xsl:param name="text"/>
<xsl:choose>
<xsl:when test="starts-with(normalize-space($text), '---')">
<xsl:variable name="after-first-delimiter" select="substring-after($text, '---')"/>
<xsl:choose>
<xsl:when test="contains($after-first-delimiter, '---')">
<xsl:variable name="yaml-content" select="substring-before($after-first-delimiter, '---')"/>
<xsl:call-template name="parse-yaml-name">
<xsl:with-param name="yaml" select="$yaml-content"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>Nameless</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>Nameless</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="parse-yaml-name">
<xsl:param name="yaml"/>
<xsl:call-template name="find-yaml-name">
<xsl:with-param name="remaining" select="$yaml"/>
</xsl:call-template>
</xsl:template>
<xsl:template name="find-yaml-name">
<xsl:param name="remaining"/>
<xsl:if test="string-length($remaining) > 0">
<xsl:variable name="line">
<xsl:choose>
<xsl:when test="contains($remaining, '&#10;')">
<xsl:value-of select="normalize-space(substring-before($remaining, '&#10;'))"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="normalize-space($remaining)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="rest">
<xsl:if test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-after($remaining, '&#10;')"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<xsl:when test="starts-with($line, 'name:')">
<xsl:value-of select="normalize-space(substring-after($line, 'name:'))"/>
</xsl:when>
<xsl:when test="string-length($rest) > 0">
<xsl:call-template name="find-yaml-name">
<xsl:with-param name="remaining" select="$rest"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>Nameless</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>
<xsl:template name="remove-yaml-frontmatter">
<xsl:param name="text"/>
<xsl:choose>
<xsl:when test="starts-with(normalize-space($text), '---')">
<xsl:variable name="after-first-delimiter" select="substring-after($text, '---')"/>
<xsl:choose>
<xsl:when test="contains($after-first-delimiter, '---')">
<xsl:value-of select="substring-after($after-first-delimiter, '---')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="check-for-headers">
<xsl:param name="text"/>
<xsl:if test="string-length($text) > 0">
<xsl:variable name="line">
<xsl:choose>
<xsl:when test="contains($text, '&#10;')">
<xsl:value-of select="substring-before($text, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="rest">
<xsl:if test="contains($text, '&#10;')">
<xsl:value-of select="substring-after($text, '&#10;')"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<xsl:when test="starts-with($line, '#')">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:when test="string-length($rest) > 0">
<xsl:call-template name="check-for-headers">
<xsl:with-param name="text" select="$rest"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>
<!-- Utility templates -->
<xsl:template name="count-heading-level">
<xsl:param name="line"/>
<xsl:param name="count" select="0"/>
<xsl:choose>
<xsl:when test="starts-with($line, '#')">
<xsl:call-template name="count-heading-level">
<xsl:with-param name="line" select="substring($line, 2)"/>
<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$count"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="close-sections">
<xsl:param name="from-level"/>
<xsl:param name="to-level"/>
<xsl:if test="$from-level > $to-level">
<xsl:text disable-output-escaping="yes">&lt;/section&gt;</xsl:text>
<xsl:call-template name="close-sections">
<xsl:with-param name="from-level" select="$from-level - 1"/>
<xsl:with-param name="to-level" select="$to-level"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="count-list-level">
<xsl:param name="line"/>
<xsl:param name="count" select="0"/>
<xsl:choose>
<xsl:when test="starts-with($line, '-') and not(starts-with($line, '- '))">
<xsl:call-template name="count-list-level">
<xsl:with-param name="line" select="substring($line, 2)"/>
<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$count + 1"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="get-list-item-text">
<xsl:param name="line"/>
<xsl:param name="level"/>
<xsl:variable name="prefix">
<xsl:call-template name="repeat-string">
<xsl:with-param name="string" select="'-'"/>
<xsl:with-param name="count" select="$level"/>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="normalize-space(substring-after($line, concat($prefix, ' ')))"/>
</xsl:template>
<xsl:template name="repeat-string">
<xsl:param name="string"/>
<xsl:param name="count"/>
<xsl:if test="$count > 0">
<xsl:value-of select="$string"/>
<xsl:call-template name="repeat-string">
<xsl:with-param name="string" select="$string"/>
<xsl:with-param name="count" select="$count - 1"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="open-lists">
<xsl:param name="from"/>
<xsl:param name="to"/>
<xsl:param name="list-type"/>
<xsl:if test="$from &lt;= $to">
<xsl:choose>
<xsl:when test="$list-type = 'ol'">
<xsl:text disable-output-escaping="yes">&lt;ol&gt;</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text disable-output-escaping="yes">&lt;ul&gt;</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="open-lists">
<xsl:with-param name="from" select="$from + 1"/>
<xsl:with-param name="to" select="$to"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="close-lists-to-level">
<xsl:param name="from"/>
<xsl:param name="to"/>
<xsl:param name="list-type"/>
<xsl:if test="$from > $to">
<xsl:choose>
<xsl:when test="$list-type = 'ol'">
<xsl:text disable-output-escaping="yes">&lt;/ol&gt;</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text disable-output-escaping="yes">&lt;/ul&gt;</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="close-lists-to-level">
<xsl:with-param name="from" select="$from - 1"/>
<xsl:with-param name="to" select="$to"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="close-lists-recursive">
<xsl:param name="level"/>
<xsl:param name="list-type"/>
<xsl:if test="$level > 0">
<xsl:choose>
<xsl:when test="$list-type = 'ol'">
<xsl:text disable-output-escaping="yes">&lt;/ol&gt;</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text disable-output-escaping="yes">&lt;/ul&gt;</xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="close-lists-recursive">
<xsl:with-param name="level" select="$level - 1"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="generate-heading-id">
<xsl:param name="text"/>
<xsl:value-of select="translate(normalize-space(translate($text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')), ' .,!?;:()', '-------')"/>
</xsl:template>
<!-- Inline processing -->
<xsl:template name="process-inline">
<xsl:param name="text"/>
<xsl:choose>
<!-- Footnotes ^[text] (toggle via css) -->
<xsl:when test="contains($text, '^[') and contains(substring-after($text, '^['), ']')">
<xsl:value-of select="substring-before($text, '^[')"/>
<xsl:variable name="footnote-text" select="substring-before(substring-after($text, '^['), ']')"/>
<xsl:variable name="after-footnote" select="substring-after($text, ']')"/>
<label class="f-n">
<input type="checkbox" hidden="hidden" name="f-n"/>
<span></span><!-- ... -->
<span><xsl:value-of select="$footnote-text"/></span>
</label>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-footnote"/>
</xsl:call-template>
</xsl:when>
<!-- Wikilinks [[page]] or [[page|text]] etc -->
<xsl:when test="contains($text, '[[') and contains(substring-after($text, '[['), ']]')">
<xsl:value-of select="substring-before($text, '[[')"/>
<xsl:variable name="wikilink-content" select="substring-before(substring-after($text, '[['), ']]')"/>
<xsl:variable name="after-wikilink" select="substring-after($text, ']]')"/>
<xsl:choose>
<xsl:when test="contains($wikilink-content, '|')">
<xsl:variable name="link-target" select="substring-before($wikilink-content, '|')"/>
<xsl:variable name="link-text" select="substring-after($wikilink-content, '|')"/>
<xsl:call-template name="process-link">
<xsl:with-param name="url" select="$link-target"/>
<xsl:with-param name="link-text" select="$link-text"/>
<xsl:with-param name="auto-generate-text" select="false()"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-link">
<xsl:with-param name="url" select="$wikilink-content"/>
<xsl:with-param name="link-text" select="$wikilink-content"/>
<xsl:with-param name="auto-generate-text" select="false()"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-wikilink"/>
</xsl:call-template>
</xsl:when>
<!-- Images ![alt](src) -->
<xsl:when test="contains($text, '![') and contains(substring-after($text, '!['), '](')">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '![')"/>
</xsl:call-template>
<xsl:variable name="after-img-start" select="substring-after($text, '![')"/>
<xsl:variable name="alt-text" select="substring-before($after-img-start, ']')"/>
<xsl:variable name="after-alt" select="substring-after($after-img-start, ']')"/>
<xsl:choose>
<xsl:when test="starts-with($after-alt, '(') and contains($after-alt, ')')">
<xsl:variable name="src" select="substring-before(substring-after($after-alt, '('), ')')"/>
<xsl:choose>
<!-- Image with alt text (toggle via css)-->
<xsl:when test="normalize-space($alt-text) != ''">
<span class="img_w_alt">
<label>
<img src="{$src}" alt="{$alt-text}"/>
<input name="i_a" type="checkbox" hidden="hidden"/>
<span></span><!--CSS contains text-->
<span><xsl:value-of select="$alt-text"/></span>
</label>
</span>
</xsl:when>
<!-- Image without alt text - regular img -->
<xsl:otherwise>
<img src="{$src}" alt=""/>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-alt, ')')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>![</xsl:text>
<xsl:value-of select="$alt-text"/>
<xsl:text>]</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-alt"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Inline code (process before '**' and '*') -->
<xsl:when test="contains($text, '`')">
<!-- Process text before backtick for other inline elements -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '`')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '`')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '`')">
<code><xsl:value-of select="substring-before($after-first, '`')"/></code>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '`')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>`</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Strike-through -->
<xsl:when test="contains($text, '~~')">
<!-- Process text before the first ~~ -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '~~')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '~~')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '~~')">
<!-- Found closing ~~ -->
<del>
<!-- Process content between ~~ tags -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($after-first, '~~')"/>
</xsl:call-template>
</del>
<!-- Process text after closing ~~ -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '~~')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<!-- No closing ~~, output as-is -->
<xsl:text>~~</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Bold -->
<xsl:when test="contains($text, '**')">
<!-- Process text before the first ** -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '**')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '**')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '**')">
<!-- Found closing ** -->
<strong>
<!-- Process content between ** tags -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($after-first, '**')"/>
</xsl:call-template>
</strong>
<!-- Process text after closing ** -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '**')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<!-- No closing **, output as-is -->
<xsl:text>**</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Italic -->
<xsl:when test="contains($text, '*')">
<!-- Process text before the first * -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '*')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '*')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '*')">
<!-- Found closing * -->
<em>
<!-- Process content between * tags -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($after-first, '*')"/>
</xsl:call-template>
</em>
<!-- Process text after closing * -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '*')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<!-- No closing *, output as-is -->
<xsl:text>*</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Links [text](url) -->
<xsl:when test="contains($text, '[') and contains(substring-after($text, '['), '](')">
<xsl:value-of select="substring-before($text, '[')"/>
<xsl:variable name="link-text" select="substring-before(substring-after($text, '['), ']')"/>
<xsl:variable name="after-bracket" select="substring-after($text, ']')"/>
<xsl:if test="starts-with($after-bracket, '(')">
<xsl:variable name="url" select="substring-before(substring-after($after-bracket, '('), ')')"/>
<xsl:call-template name="process-link">
<xsl:with-param name="url" select="$url"/>
<xsl:with-param name="link-text" select="$link-text"/>
<xsl:with-param name="auto-generate-text" select="true()"/>
</xsl:call-template>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-bracket, ')')"/>
</xsl:call-template>
</xsl:if>
</xsl:when>
<!-- Line breaks (two spaces at end) -->
<xsl:when test="substring($text, string-length($text) - 1) = '  '">
<xsl:value-of select="substring($text, 1, string-length($text) - 2)"/>
<br/>
</xsl:when>
<!-- Raw URLs (`text http:// or https:// text`)
process last to avoid conflicts with marked up links -->
<xsl:when test="contains($text, 'http://') or contains($text, 'https://')">
<xsl:choose>
<xsl:when test="contains($text, 'https://')">
<xsl:call-template name="process-raw-url">
<xsl:with-param name="text" select="$text"/>
<xsl:with-param name="protocol" select="'https://'"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-raw-url">
<xsl:with-param name="text" select="$text"/>
<xsl:with-param name="protocol" select="'http://'"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- END OF INLINE No more inline elements -->
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!-- TOC generation -->
<xsl:template name="generate-toc">
<xsl:param name="text"/>
<xsl:param name="in-code-block" select="false()"/>
<xsl:param name="in-blockquote" select="false()"/>
<xsl:if test="string-length($text) > 0">
<xsl:variable name="line">
<xsl:choose>
<xsl:when test="contains($text, '&#10;')">
<xsl:value-of select="substring-before($text, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="rest">
<xsl:if test="contains($text, '&#10;')">
<xsl:value-of select="substring-after($text, '&#10;')"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<!-- Handle code block/blockquote state changes -->
<xsl:when test="starts-with($line, '```')">
<xsl:choose>
<!-- Starting blockquote -->
<xsl:when test="starts-with($line, '```blockquote') and $in-blockquote = false()">
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="true()"/>
</xsl:call-template>
</xsl:when>
<!-- Ending blockquote -->
<xsl:when test="$line = '```' and $in-blockquote = true()">
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
</xsl:call-template>
</xsl:when>
<!-- Ending code block -->
<xsl:when test="$in-code-block = true()">
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
</xsl:call-template>
</xsl:when>
<!-- Starting code block -->
<xsl:otherwise>
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-code-block" select="true()"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Check if this line is a header (only if not in code block or blockquote) -->
<xsl:when test="starts-with($line, '#') and $in-code-block = false() and $in-blockquote = false()">
<xsl:variable name="heading-text" select="normalize-space(translate($line, '#', ''))"/>
<xsl:variable name="heading-id">
<xsl:call-template name="generate-heading-id">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
</xsl:variable>
<!-- Determine heading level -->
<xsl:variable name="heading-level">
<xsl:choose>
<xsl:when test="starts-with($line, '######')">6</xsl:when>
<xsl:when test="starts-with($line, '#####')">5</xsl:when>
<xsl:when test="starts-with($line, '####')">4</xsl:when>
<xsl:when test="starts-with($line, '###')">3</xsl:when>
<xsl:when test="starts-with($line, '##')">2</xsl:when>
<xsl:when test="starts-with($line, '#')">1</xsl:when>
</xsl:choose>
</xsl:variable>
<li class="toc-h{$heading-level}">
<a href="#{$heading-id}" tabindex="0">
<xsl:value-of select="$heading-text"/>
</a>
</li>
<!-- Continue with the rest -->
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
</xsl:call-template>
</xsl:when>
<!-- Continue with the rest (not a header nor state change) -->
<xsl:otherwise>
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>
<!-- Link processing templates -->
<xsl:template name="make-wiki-url">
<xsl:param name="text"/>
<xsl:param name="no-extension" select="false()"/>
<xsl:variable name="trimmed" select="normalize-space($text)"/>
<xsl:variable name="lowercase" select="translate($trimmed, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
<xsl:variable name="with-dashes" select="translate($lowercase, ' ', '-')"/>
<xsl:choose>
<xsl:when test="$no-extension = true()">
<xsl:value-of select="$with-dashes"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat($with-dashes, '.xml')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="process-link">
<xsl:param name="url"/>
<xsl:param name="link-text"/>
<xsl:param name="auto-generate-text" select="false()"/>
<xsl:variable name="final-link-text">
<xsl:choose>
<xsl:when test="normalize-space($link-text) = '' and $auto-generate-text = true()">
<xsl:choose>
<!-- Jump link with no text. use anchor part -->
<xsl:when test="starts-with($url, '#')">
<xsl:value-of select="substring-after($url, '#')"/>
</xsl:when>
<!-- Local page with anchor. use anchor part -->
<xsl:when test="contains($url, '#') and not(contains($url, '://'))">
<xsl:value-of select="substring-after($url, '#')"/>
</xsl:when>
<!-- Other URLs. use URL processing -->
<xsl:otherwise>
<xsl:call-template name="generate-link-text-from-url">
<xsl:with-param name="url" select="$url"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$link-text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<!-- Same page jump link (#anchor) -->
<xsl:when test="starts-with($url, '#')">
<xsl:variable name="anchor-part" select="substring-after($url, '#')"/>
<xsl:variable name="processed-anchor">
<xsl:call-template name="make-wiki-url">
<xsl:with-param name="text" select="$anchor-part"/>
<xsl:with-param name="no-extension" select="true()"/>
</xsl:call-template>
</xsl:variable>
<!-- Remove any '#' from link text -->
<xsl:variable name="clean-link-text">
<xsl:choose>
<xsl:when test="starts-with($final-link-text, '#')">
<xsl:value-of select="substring-after($final-link-text, '#')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$final-link-text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<a href="#{$processed-anchor}" tabindex="0"><xsl:value-of select="$clean-link-text"/></a>
</xsl:when>
<!-- Different page with anchor (page.xml#anchor) -->
<xsl:when test="contains($url, '#') and not(contains($url, '://'))">
<xsl:variable name="page-part" select="substring-before($url, '#')"/>
<xsl:variable name="anchor-part" select="substring-after($url, '#')"/>
<xsl:variable name="processed-page">
<xsl:call-template name="process-page-url">
<xsl:with-param name="url" select="$page-part"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="processed-anchor">
<xsl:call-template name="make-wiki-url">
<xsl:with-param name="text" select="$anchor-part"/>
<xsl:with-param name="no-extension" select="true()"/>
</xsl:call-template>
</xsl:variable>
<!-- Add title attribute with page name -->
<a href="{$processed-page}#{$processed-anchor}" title="{$page-part}" tabindex="0">
<xsl:value-of select="$final-link-text"/>
</a>
</xsl:when>
<!-- External URL (contains ://) -->
<xsl:when test="contains($url, '://')">
<a href="{$url}" tabindex="0"><xsl:value-of select="$final-link-text"/></a>
</xsl:when>
<!-- Local page -->
<xsl:otherwise>
<xsl:variable name="processed-page">
<xsl:call-template name="process-page-url">
<xsl:with-param name="url" select="$url"/>
</xsl:call-template>
</xsl:variable>
<a href="{$processed-page}" tabindex="0"><xsl:value-of select="$final-link-text"/></a>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="process-page-url">
<xsl:param name="url"/>
<xsl:choose>
<!-- Already has extension, just process case/spaces -->
<xsl:when test="contains($url, '.')">
<xsl:call-template name="make-wiki-url">
<xsl:with-param name="text" select="substring-before($url, '.')"/>
<xsl:with-param name="no-extension" select="true()"/>
</xsl:call-template>
<xsl:text>.</xsl:text>
<xsl:value-of select="substring-after($url, '.')"/>
</xsl:when>
<!-- lacks extension, add .xml and process -->
<xsl:otherwise>
<xsl:call-template name="make-wiki-url">
<xsl:with-param name="text" select="$url"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="generate-link-text-from-url">
<xsl:param name="url"/>
<xsl:variable name="clean-url">
<xsl:choose>
<!-- Remove https:// -->
<xsl:when test="starts-with($url, 'https://')">
<xsl:value-of select="substring-after($url, 'https://')"/>
</xsl:when>
<!-- Remove http:// -->
<xsl:when test="starts-with($url, 'http://')">
<xsl:value-of select="substring-after($url, 'http://')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$url"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="without-www">
<xsl:choose>
<xsl:when test="starts-with($clean-url, 'www.')">
<xsl:value-of select="substring-after($clean-url, 'www.')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$clean-url"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<!-- get domain part (before / or #) -->
<xsl:when test="contains($without-www, '/')">
<xsl:value-of select="substring-before($without-www, '/')"/>
</xsl:when>
<xsl:when test="contains($without-www, '#')">
<xsl:value-of select="substring-before($without-www, '#')"/>
</xsl:when>
<!-- Remove any .xml extension present -->
<xsl:when test="substring($without-www, string-length($without-www) - 3) = '.xml'">
<xsl:value-of select="substring($without-www, 1, string-length($without-www) - 4)"/>
</xsl:when>
<!-- Remove other extensions -->
<xsl:when test="contains($without-www, '.')">
<xsl:value-of select="substring-before($without-www, '.')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$without-www"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="process-raw-url">
<xsl:param name="text"/>
<xsl:param name="protocol"/>
<xsl:variable name="before-url" select="substring-before($text, $protocol)"/>
<xsl:variable name="url-and-after" select="substring-after($text, $protocol)"/>
<!-- Check if this URL falls inside '[]' or '[[' (avoid double processing) -->
<xsl:variable name="char-before">
<xsl:if test="string-length($before-url) > 0">
<xsl:value-of select="substring($before-url, string-length($before-url))"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<!-- Skip url inside Markdown/wiki links -->
<xsl:when test="$char-before = '(' or $char-before = ']'">
<xsl:value-of select="$text"/>
</xsl:when>
<xsl:otherwise>
<!-- Process text before URL -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$before-url"/>
</xsl:call-template>
<!-- Extract raw URL (until space or end) -->
<xsl:variable name="url-part">
<xsl:choose>
<xsl:when test="contains($url-and-after, ' ')">
<xsl:value-of select="substring-before($url-and-after, ' ')"/>
</xsl:when>
<xsl:when test="contains($url-and-after, '&#10;')">
<xsl:value-of select="substring-before($url-and-after, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$url-and-after"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!-- Create link -->
<xsl:variable name="full-url" select="concat($protocol, $url-part)"/>
<a href="{$full-url}" tabindex="0"><xsl:value-of select="$full-url"/></a>
<!-- Process remaining text -->
<xsl:variable name="after-url" select="substring-after($url-and-after, $url-part)"/>
<xsl:if test="string-length($after-url) > 0">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-url"/>
</xsl:call-template>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!-- Table processing templates -->
<xsl:template name="collect-until-marker">
<xsl:param name="text"/>
<xsl:param name="marker"/>
<xsl:choose>
<xsl:when test="contains($text, $marker)">
<xsl:value-of select="substring-before($text, $marker)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="skip-until-after-marker">
<xsl:param name="text"/>
<xsl:param name="marker"/>
<xsl:choose>
<xsl:when test="contains($text, $marker)">
<xsl:value-of select="substring-after($text, $marker)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="''"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="parse-table-content">
<xsl:param name="content"/>
<!-- Remove outer brackets and whitespace -->
<xsl:variable name="trimmed">
<xsl:call-template name="trim-table-content">
<xsl:with-param name="text" select="normalize-space($content)"/>
</xsl:call-template>
</xsl:variable>
<!-- Process rows -->
<xsl:call-template name="parse-table-rows">
<xsl:with-param name="text" select="$trimmed"/>
<xsl:with-param name="is-first" select="true()"/>
</xsl:call-template>
</xsl:template>
<xsl:template name="trim-table-content">
<xsl:param name="text"/>
<xsl:variable name="no-leading-bracket">
<xsl:choose>
<xsl:when test="starts-with($text, '[')">
<xsl:value-of select="substring($text, 2)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="substring($no-leading-bracket, string-length($no-leading-bracket)) = ']'">
<xsl:value-of select="substring($no-leading-bracket, 1, string-length($no-leading-bracket) - 1)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$no-leading-bracket"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="parse-table-rows">
<xsl:param name="text"/>
<xsl:param name="is-first"/>
<xsl:if test="contains($text, '[') and contains($text, ']')">
<!-- Extract one row -->
<xsl:variable name="before-row" select="substring-before($text, '[')"/>
<xsl:variable name="after-bracket" select="substring-after($text, '[')"/>
<xsl:variable name="row-content">
<xsl:call-template name="substring-before-unquoted">
<xsl:with-param name="text" select="$after-bracket"/>
<xsl:with-param name="delim" select="']'"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="after-row" select="substring-after($after-bracket, ']')"/>
<!-- Process the row -->
<tr>
<xsl:call-template name="parse-table-cells">
<xsl:with-param name="text" select="$row-content"/>
<xsl:with-param name="is-header" select="$is-first"/>
</xsl:call-template>
</tr>
<!-- Continue with remaining rows -->
<xsl:call-template name="parse-table-rows">
<xsl:with-param name="text" select="$after-row"/>
<xsl:with-param name="is-first" select="false()"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template name="substring-before-unquoted">
<xsl:param name="text"/>
<xsl:param name="delim"/>
<xsl:param name="in-string" select="false()"/>
<xsl:choose>
<!-- End of text -->
<xsl:when test="string-length($text)=0">
<xsl:value-of select="''"/>
</xsl:when>
<!-- Look at first character -->
<xsl:otherwise>
<xsl:variable name="first" select="substring($text,1,1)"/>
<xsl:variable name="rest" select="substring($text,2)"/>
<!-- Toggle string state on quote -->
<xsl:choose>
<xsl:when test="$first='&quot;'">
<xsl:value-of select="$first"/>
<xsl:call-template name="substring-before-unquoted">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="delim" select="$delim"/>
<xsl:with-param name="in-string" select="not($in-string)"/>
</xsl:call-template>
</xsl:when>
<!-- Found delimiter outside string -->
<xsl:when test="not($in-string) and $first=$delim">
<!-- stop before delim -->
</xsl:when>
<!-- Otherwise keep scanning -->
<xsl:otherwise>
<xsl:value-of select="$first"/>
<xsl:call-template name="substring-before-unquoted">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="delim" select="$delim"/>
<xsl:with-param name="in-string" select="$in-string"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="parse-table-cells">
<xsl:param name="text"/>
<xsl:param name="is-header"/>
<xsl:if test="contains($text, '&quot;')">
<xsl:variable name="before-quote" select="substring-before($text, '&quot;')"/>
<xsl:variable name="after-first-quote" select="substring-after($text, '&quot;')"/>
<xsl:variable name="cell-content" select="substring-before($after-first-quote, '&quot;')"/>
<xsl:variable name="after-cell" select="substring-after($after-first-quote, '&quot;')"/>
<xsl:choose>
<xsl:when test="$is-header">
<th>
<xsl:call-template name="process-smart-cell-content">
<xsl:with-param name="content" select="$cell-content"/>
</xsl:call-template>
</th>
</xsl:when>
<xsl:otherwise>
<td>
<xsl:call-template name="process-smart-cell-content">
<xsl:with-param name="content" select="$cell-content"/>
</xsl:call-template>
</td>
</xsl:otherwise>
</xsl:choose>
<!-- Continue if more cells -->
<xsl:if test="contains($after-cell, '&quot;')">
<xsl:call-template name="parse-table-cells">
<xsl:with-param name="text" select="$after-cell"/>
<xsl:with-param name="is-header" select="$is-header"/>
</xsl:call-template>
</xsl:if>
</xsl:if>
</xsl:template>
<xsl:template name="process-smart-cell-content">
<xsl:param name="content"/>
<!-- Pre-process: convert JSON escape sequences to characters -->
<xsl:variable name="processed-content">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="$content"/>
</xsl:call-template>
</xsl:variable>
<!-- Check for paragraph breaks in the processed content -->
<xsl:choose>
<xsl:when test="contains($processed-content, '&#10;&#10;')">
<!-- Multi-paragraph content -->
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$processed-content"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</xsl:when>
<!-- Content with single line breaks -->
<xsl:when test="contains($processed-content, '&#10;')">
<xsl:call-template name="process-lines-with-breaks">
<xsl:with-param name="text" select="$processed-content"/>
</xsl:call-template>
</xsl:when>
<!-- Single line with no breaks - just apply inline formatting -->
<xsl:otherwise>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space($processed-content)"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="process-lines-with-breaks">
<xsl:param name="text"/>
<xsl:choose>
<xsl:when test="contains($text, '&#10;')">
<!-- Get the current line -->
<xsl:variable name="current-line" select="substring-before($text, '&#10;')"/>
<!-- Get the rest of the text -->
<xsl:variable name="remaining" select="substring-after($text, '&#10;')"/>
<!-- Process the current line -->
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space($current-line)"/>
</xsl:call-template>
<!-- Add a space to join lines (not <br/>) -->
<xsl:text> </xsl:text>
<!-- Process the rest -->
<xsl:call-template name="process-lines-with-breaks">
<xsl:with-param name="text" select="$remaining"/>
</xsl:call-template>
</xsl:when>
<!-- Last line or no more breaks -->
<xsl:otherwise>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space($text)"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="unescape-json-string">
<xsl:param name="text"/>
<xsl:choose>
<!-- \n to  newline -->
<xsl:when test="contains($text, '\n')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\n'), '&#10;', substring-after($text, '\n'))"/>
</xsl:call-template>
</xsl:when>
<!-- \r to  carriage return -->
<xsl:when test="contains($text, '\r')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\r'), '&#13;', substring-after($text, '\r'))"/>
</xsl:call-template>
</xsl:when>
<!-- \t to tab -->
<xsl:when test="contains($text, '\t')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\t'), '&#9;', substring-after($text, '\t'))"/>
</xsl:call-template>
</xsl:when>
<!-- '\\' to '\' -->
<xsl:when test="contains($text, '\\')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\\'), '\', substring-after($text, '\\'))"/>
</xsl:call-template>
</xsl:when>
<!-- No more escape sequences -->
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!-- Error handling -->
<xsl:template match="*">
<div class="markdown-error">
<p>Error processing Markdown content</p>
<pre><xsl:value-of select="."/></pre>
</div>
</xsl:template>
</xsl:stylesheet>