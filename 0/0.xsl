<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:exsl="http://exslt.org/common"
extension-element-prefixes="exsl"
>
<xsl:import href="pages.xsl"/>
<xsl:output
method="html"
indent="yes"
encoding="UTF-8"
doctype-system="about:legacy-compat"
/>

<!-- Main -->
<xsl:template match="/">
<xsl:variable name="page-title">
<xsl:call-template name="extract-yaml-title">
<xsl:with-param name="text" select="." />
</xsl:call-template>
</xsl:variable>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="color-scheme" content="light dark" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link href="../0/0.css" rel="stylesheet" />
<title>Skip 
<xsl:if test="normalize-space($page-title) != ''">
  <xsl:text> - </xsl:text>
  <xsl:value-of select="$page-title" />
</xsl:if>
</title>
</head>
<body>
<a href="#post" class="skip_link" accesskey="3" tabindex="0">
<span title="Access Key 3">Skip to main content</span>
</a>
<div id="_nav_and_main">
<nav id="site_nav">
<ul>
<li><a href="index.xml">Home</a></li>
<li><a href="parts.xml">Parts</a></li>
<li><a href="log.xml">Log</a></li>
<li><a href="info.xml">Info</a></li>
</ul>
</nav>
<main>
<header id="top">
<xsl:choose>
  <xsl:when test="normalize-space($page-title) != ''">
    <h1 class="h">
      <xsl:value-of select="$page-title" />
      <a href="#top" title="Access Key 1" accesskey="1">#</a>
    </h1>
  </xsl:when>
  <xsl:otherwise>
    <a href="#top" title="Access Key 1" accesskey="1"></a>
  </xsl:otherwise>
</xsl:choose>
</header>

<xsl:variable name="content">
<xsl:call-template name="serialize-mixed-content">
<xsl:with-param name="nodes" select="/*/node()"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="has-headers">
<xsl:call-template name="check-for-headers">
<xsl:with-param name="text" select="$content" />
</xsl:call-template>
</xsl:variable>

<!-- Lead content -->
<xsl:if test="$has-headers = 'true'">
<xsl:variable name="lead-content">
<xsl:call-template name="extract-lead-content">
<xsl:with-param name="text" select="$content" />
</xsl:call-template>
</xsl:variable>
<xsl:if test="normalize-space($lead-content) != ''">
<section class="lead">
<xsl:call-template name="process-mixed-text">
<xsl:with-param name="text" select="$lead-content" />
<xsl:with-param name="enable-sections" select="false()" />
</xsl:call-template>
</section>
</xsl:if>
</xsl:if>

<!-- TOC -->
<xsl:if test="$has-headers = 'true'">
<details id="map_holder">
<summary tabindex="0" title="Access Key 2" accesskey="2"><span>Map</span></summary>
<div id="map">
<ul>
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$content" />
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
<xsl:with-param name="text" select="$content" />
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="process-mixed-text">
<xsl:with-param name="text" select="$content-from-first-header" />
<xsl:with-param name="enable-sections" select="true()" />
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-mixed-text">
<xsl:with-param name="text" select="$content" />
<xsl:with-param name="enable-sections" select="false()" />
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
<xsl:if test="pages">
<xsl:call-template name="simple-nav-list"/>
</xsl:if>
</article>
</main>

<xsl:call-template name="prev-next-nav">
<xsl:with-param name="current-page-name" select="$page-title"/>
</xsl:call-template>
</div>
<footer>
<span
title="SKIP Parses plain text, mark up and Markdown to HTML via .xsl (XSLT 1.0) sheet. By and copyright Greg Abbott 2025. First Version: 2025-08-26. Version: 2025-09-03">
&#169; 2025
<a href="https://gregabbott.pages.dev/">Greg Abbott</a>.
</span>
<a id="to_top" href="#top">Top</a>
<ul><li><a href="pages.xml">Pages</a></li></ul>
</footer>
</body>
</html>
</xsl:template>

<!-- Previous and Next Page Nav -->
<xsl:template name="prev-next-nav">
<xsl:param name="current-page-name"/>
<xsl:variable name="page-list" select="exsl:node-set($ps)/p"/>
<xsl:variable name="matching-page" select="$page-list[@n = $current-page-name]"/>
<xsl:if test="$matching-page">
<xsl:variable name="current-position" select="count($matching-page/preceding-sibling::p) + 1"/>
<xsl:variable name="total-pages" select="count($page-list)"/>
<xsl:variable name="has-newer" select="$current-position > 1"/>
<xsl:variable name="has-older" select="$current-position &lt; $total-pages"/>
<xsl:if test="$has-newer or $has-older">
<nav class="older_newer">
<hr/>
<xsl:choose>
<xsl:when test="$has-older">
<xsl:variable name="older-page" select="$page-list[$current-position + 1]"/>
<div class="older_post">
<a tabindex="0" href="{$older-page/@u}.xml">
<span>Older</span><br/>
<span><xsl:value-of select="$older-page/@n"/></span>
</a>
</div>
</xsl:when>
<xsl:otherwise>
<div class="no_older_post">
<span>
<span>Older</span><br/>
<span>No older posts</span>
</span>
</div>
</xsl:otherwise>
</xsl:choose>
<xsl:choose>
<xsl:when test="$has-newer">
<xsl:variable name="newer-page" select="$page-list[$current-position - 1]"/>
<div class="newer_post">
<a tabindex="0" href="{$newer-page/@u}.xml">
<span>Newer</span><br/>
<span><xsl:value-of select="$newer-page/@n"/></span>
</a>
</div>
</xsl:when>
<xsl:otherwise>
<div class="no_newer_post">
<span>
<span>Newer</span><br/>
<span>No newer posts</span>
</span>
</div>
</xsl:otherwise>
</xsl:choose>
</nav>
</xsl:if>
</xsl:if>
</xsl:template>

<xsl:template name="simple-nav-list">
<ul>
<xsl:for-each select="exsl:node-set($ps)/p">
<li>
<a href="{@u}.xml">
<xsl:value-of select="@d"/>
<xsl:text> </xsl:text>
<xsl:value-of select="@n"/>
</a>
</li>
</xsl:for-each>
</ul>
</xsl:template>

<!-- ==================== CORE PROCESSING ==================== -->

<xsl:template name="process-content">
<xsl:param name="text"/>
<xsl:param name="enable-sections" select="false()"/>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$text"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:template>

<xsl:template name="process-lines">
<xsl:param name="remaining"/>
<xsl:param name="in-code-block"/>
<xsl:param name="in-blockquote"/>
<xsl:param name="in-details"/>
<xsl:param name="paragraph-acc"/>
<xsl:param name="enable-sections"/>

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
<!-- Handle triple backticks -->
<xsl:when test="starts-with($line, '```')">
<xsl:choose>
<!-- Starting code block -->
<xsl:when test="not($in-code-block) and not($in-blockquote) and not($in-details) and $line = '```'">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:variable name="code-content">
<xsl:call-template name="extract-until-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:variable>
<pre><code><xsl:value-of select="$code-content"/></code></pre>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining">
<xsl:call-template name="skip-past-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:with-param>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Starting blockquote -->
<xsl:when test="not($in-code-block) and not($in-blockquote) and not($in-details) and starts-with($line, '```blockquote')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:variable name="bq-content">
<xsl:call-template name="extract-until-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:variable>
<blockquote>
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$bq-content"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</blockquote>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining">
<xsl:call-template name="skip-past-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:with-param>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Starting details -->
<xsl:when test="not($in-code-block) and not($in-blockquote) and not($in-details) and starts-with($line, '```details')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:variable name="summary-text">
<xsl:variable name="after-details" select="normalize-space(substring-after($line, '```details'))"/>
<xsl:choose>
<xsl:when test="starts-with($after-details, '&quot;') and contains(substring-after($after-details, '&quot;'), '&quot;')">
<xsl:value-of select="substring-before(substring-after($after-details, '&quot;'), '&quot;')"/>
</xsl:when>
<xsl:otherwise>Details</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="details-content">
<xsl:call-template name="extract-until-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:variable>
<details>
<summary><xsl:value-of select="$summary-text"/></summary>
<div>
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$details-content"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</div>
</details>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining">
<xsl:call-template name="skip-past-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:with-param>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Starting table -->
<xsl:when test="not($in-code-block) and not($in-blockquote) and not($in-details) and starts-with($line, '```table')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:variable name="table-content">
<xsl:call-template name="extract-until-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:variable>
<table border="1" cellpadding="0" cellspacing="0">
<xsl:call-template name="parse-table-content">
<xsl:with-param name="content" select="$table-content"/>
</xsl:call-template>
</table>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining">
<xsl:call-template name="skip-past-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="'```'"/>
</xsl:call-template>
</xsl:with-param>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>
</xsl:choose>
</xsl:when>

<!-- Empty line -->
<xsl:when test="normalize-space($line) = ''">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-details" select="$in-details"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Headers -->
<xsl:when test="starts-with($line, '#')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:choose>
<xsl:when test="$enable-sections">
<xsl:call-template name="process-with-sections">
<xsl:with-param name="remaining" select="$remaining"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-heading">
<xsl:with-param name="line" select="$line"/>
<xsl:with-param name="shift-level" select="false()"/>
</xsl:call-template>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>

<!-- Task list items -->
<xsl:when test="starts-with($line, '- [ ]') or starts-with($line, '- [x]') or starts-with($line, '- [X]')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:call-template name="process-list-block">
<xsl:with-param name="remaining" select="$remaining"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Ordered lists -->
<xsl:when test="substring($line, 1, 1) &gt;= '0' and substring($line, 1, 1) &lt;= '9' and contains(substring($line, 1, 5), '. ')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:call-template name="process-list-block">
<xsl:with-param name="remaining" select="$remaining"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Unordered lists -->
<xsl:when test="starts-with($line, '- ') or starts-with($line, '--')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:call-template name="process-list-block">
<xsl:with-param name="remaining" select="$remaining"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Horizontal rule -->
<xsl:when test="$line = '---' or $line = '***' or $line = '___'">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<hr/>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-details" select="$in-details"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Image-only line -->
<xsl:when test="starts-with(normalize-space($line), '![') and substring(normalize-space($line), string-length(normalize-space($line))) = ')' and contains($line, '](')">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space($line)"/>
</xsl:call-template>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-details" select="$in-details"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:when>

<!-- Regular content -->
<xsl:otherwise>
<xsl:variable name="new-acc">
<xsl:choose>
<xsl:when test="normalize-space($paragraph-acc) = ''">
<xsl:value-of select="normalize-space($line)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat($paragraph-acc, ' ', normalize-space($line))"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest"/>
<xsl:with-param name="in-code-block" select="$in-code-block"/>
<xsl:with-param name="in-blockquote" select="$in-blockquote"/>
<xsl:with-param name="in-details" select="$in-details"/>
<xsl:with-param name="paragraph-acc" select="$new-acc"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:if>

<!-- End of content -->
<xsl:if test="string-length($remaining) = 0">
<xsl:call-template name="flush-paragraph">
<xsl:with-param name="paragraph" select="$paragraph-acc"/>
</xsl:call-template>
</xsl:if>
</xsl:template>

<!-- ==================== SECTION PROCESSING ==================== -->

<xsl:template name="process-with-sections">
<xsl:param name="remaining"/>
<xsl:param name="count" select="0"/>
<xsl:if test="normalize-space($remaining) != '' and $count &lt; 100">
<xsl:variable name="first-line">
<xsl:choose>
<xsl:when test="contains($remaining, '&#10;')">
<xsl:value-of select="substring-before($remaining, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$remaining"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:choose>
<xsl:when test="starts-with($first-line, '#')">
<xsl:variable name="section-content">
<xsl:call-template name="get-section-content">
<xsl:with-param name="text" select="$remaining"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="rest-content">
<xsl:call-template name="get-rest-after-section">
<xsl:with-param name="text" select="$remaining"/>
</xsl:call-template>
</xsl:variable>

<section>
<div>
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$section-content"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</div>
</section>

<xsl:if test="normalize-space($rest-content) != ''">
<xsl:call-template name="process-with-sections">
<xsl:with-param name="remaining" select="$rest-content"/>
<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:if>
</xsl:when>
<xsl:otherwise>
<!-- No header found, process as regular content -->
<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$remaining"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

<xsl:template name="get-section-content">
<xsl:param name="text"/>
<xsl:param name="accumulator" select="''"/>
<xsl:param name="in-block" select="false()"/>
<xsl:param name="started" select="false()"/>
<xsl:param name="depth" select="0"/>

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
<xsl:when test="string-length($text) = 0 or $depth > 500">
<xsl:value-of select="$accumulator"/>
</xsl:when>
<xsl:when test="starts-with($line, '```')">
<xsl:call-template name="get-section-content">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="accumulator" select="concat($accumulator, $line, '&#10;')"/>
<xsl:with-param name="in-block" select="not($in-block)"/>
<xsl:with-param name="started" select="$started"/>
<xsl:with-param name="depth" select="$depth + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="starts-with($line, '#') and not($in-block) and $started">
<xsl:value-of select="$accumulator"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="get-section-content">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="accumulator" select="concat($accumulator, $line, '&#10;')"/>
<xsl:with-param name="in-block" select="$in-block"/>
<xsl:with-param name="started" select="true()"/>
<xsl:with-param name="depth" select="$depth + 1"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="get-rest-after-section">
<xsl:param name="text"/>
<xsl:param name="in-block" select="false()"/>
<xsl:param name="started" select="false()"/>
<xsl:param name="depth" select="0"/> 

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
<xsl:when test="string-length($text) = 0 or $depth > 500"></xsl:when>
<xsl:when test="starts-with($line, '```')">
<xsl:call-template name="get-rest-after-section">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-block" select="not($in-block)"/>
<xsl:with-param name="started" select="$started"/>
<xsl:with-param name="depth" select="$depth + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="starts-with($line, '#') and not($in-block) and $started">
<xsl:value-of select="$text"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="get-rest-after-section">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-block" select="$in-block"/>
<xsl:with-param name="started" select="true()"/>
<xsl:with-param name="depth" select="$depth + 1"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ==================== LIST PROCESSING ==================== -->

<xsl:template name="process-list-block">
<xsl:param name="remaining"/>
<xsl:param name="enable-sections"/>

<xsl:variable name="list-lines">
<xsl:call-template name="collect-list-lines">
<xsl:with-param name="text" select="$remaining"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="rest-after-list">
<xsl:call-template name="skip-list-lines">
<xsl:with-param name="text" select="$remaining"/>
</xsl:call-template>
</xsl:variable>

<xsl:call-template name="build-lists">
<xsl:with-param name="text" select="$list-lines"/>
</xsl:call-template>

<xsl:call-template name="process-lines">
<xsl:with-param name="remaining" select="$rest-after-list"/>
<xsl:with-param name="in-code-block" select="false()"/>
<xsl:with-param name="in-blockquote" select="false()"/>
<xsl:with-param name="in-details" select="false()"/>
<xsl:with-param name="paragraph-acc" select="''"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:template>

<xsl:template name="collect-list-lines">
<xsl:param name="text"/>
<xsl:param name="accumulator" select="''"/>

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

<xsl:variable name="is-list-item">
<xsl:choose>
<xsl:when test="starts-with($line, '- [ ]') or starts-with($line, '- [x]') or starts-with($line, '- [X]')">true</xsl:when>
<xsl:when test="substring($line, 1, 1) &gt;= '0' and substring($line, 1, 1) &lt;= '9' and contains(substring($line, 1, 5), '. ')">true</xsl:when>
<xsl:when test="starts-with($line, '- ') or starts-with($line, '--')">true</xsl:when>
<xsl:otherwise>false</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:choose>
<xsl:when test="$is-list-item = 'true' and string-length($rest) > 0">
<xsl:call-template name="collect-list-lines">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="accumulator" select="concat($accumulator, $line, '&#10;')"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="$is-list-item = 'true'">
<xsl:value-of select="concat($accumulator, $line)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$accumulator"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="skip-list-lines">
<xsl:param name="text"/>

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

<xsl:variable name="is-list-item">
<xsl:choose>
<xsl:when test="starts-with($line, '- [ ]') or starts-with($line, '- [x]') or starts-with($line, '- [X]')">true</xsl:when>
<xsl:when test="substring($line, 1, 1) &gt;= '0' and substring($line, 1, 1) &lt;= '9' and contains(substring($line, 1, 5), '. ')">true</xsl:when>
<xsl:when test="starts-with($line, '- ') or starts-with($line, '--')">true</xsl:when>
<xsl:otherwise>false</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:choose>
<xsl:when test="$is-list-item = 'true' and string-length($rest) > 0">
<xsl:call-template name="skip-list-lines">
<xsl:with-param name="text" select="$rest"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="$is-list-item = 'false'">
<xsl:value-of select="$text"/>
</xsl:when>
</xsl:choose>
</xsl:template>

<xsl:template name="build-lists">
<xsl:param name="text"/>
<xsl:if test="normalize-space($text) != ''">
<xsl:variable name="first-line">
<xsl:choose>
<xsl:when test="contains($text, '&#10;')">
<xsl:value-of select="substring-before($text, '&#10;')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="first-type">
<xsl:choose>
<xsl:when test="substring($first-line, 1, 1) &gt;= '0' and substring($first-line, 1, 1) &lt;= '9' and contains(substring($first-line, 1, 5), '. ')">ol</xsl:when>
<xsl:otherwise>ul</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:element name="{$first-type}">
<xsl:call-template name="build-list-items">
<xsl:with-param name="text" select="$text"/>
<xsl:with-param name="list-type" select="$first-type"/>
</xsl:call-template>
</xsl:element>
</xsl:if>
</xsl:template>

<xsl:template name="build-list-items">
<xsl:param name="text"/>
<xsl:param name="list-type"/>

<xsl:if test="normalize-space($text) != ''">
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

<!-- Task list item -->
<xsl:choose>
<xsl:when test="starts-with($line, '- [ ]') or starts-with($line, '- [x]') or starts-with($line, '- [X]')">
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
</xsl:when>

<!-- Ordered list item -->
<xsl:when test="substring($line, 1, 1) &gt;= '0' and substring($line, 1, 1) &lt;= '9' and contains(substring($line, 1, 5), '. ')">
<li>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space(substring-after($line, '. '))"/>
</xsl:call-template>
</li>
</xsl:when>

<!-- Nested list -->
<xsl:when test="starts-with($line, '--')">
<li>
<xsl:variable name="nested-lines">
<xsl:call-template name="collect-nested-items">
<xsl:with-param name="text" select="$text"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="build-lists">
<xsl:with-param name="text" select="$nested-lines"/>
</xsl:call-template>
</li>
<xsl:call-template name="build-list-items">
<xsl:with-param name="text">
<xsl:call-template name="skip-nested-items">
<xsl:with-param name="text" select="$text"/>
</xsl:call-template>
</xsl:with-param>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:when>

<!-- Regular list item -->
<xsl:when test="starts-with($line, '- ')">
<li>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($line, '- ')"/>
</xsl:call-template>
</li>
</xsl:when>
</xsl:choose>

<xsl:if test="normalize-space($rest) != '' and not(starts-with($line, '--'))">
<xsl:call-template name="build-list-items">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="list-type" select="$list-type"/>
</xsl:call-template>
</xsl:if>
</xsl:if>
</xsl:template>

<xsl:template name="collect-nested-items">
<xsl:param name="text"/>
<xsl:param name="accumulator" select="''"/>

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
<xsl:when test="starts-with($line, '--') and string-length($rest) > 0">
<xsl:call-template name="collect-nested-items">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="accumulator" select="concat($accumulator, substring($line, 2), '&#10;')"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="starts-with($line, '--')">
<xsl:value-of select="concat($accumulator, substring($line, 2))"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$accumulator"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="skip-nested-items">
<xsl:param name="text"/>

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
<xsl:when test="starts-with($line, '--') and string-length($rest) > 0">
<xsl:call-template name="skip-nested-items">
<xsl:with-param name="text" select="$rest"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="not(starts-with($line, '--'))">
<xsl:value-of select="$text"/>
</xsl:when>
</xsl:choose>
</xsl:template>

<!-- ==================== HELPER TEMPLATES ==================== -->

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

<xsl:template name="extract-until-marker">
<xsl:param name="text"/>
<xsl:param name="marker"/>
<xsl:param name="accumulator" select="''"/>

<xsl:choose>
<xsl:when test="string-length($text) = 0">
<xsl:value-of select="$accumulator"/>
</xsl:when>
<xsl:otherwise>
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
<xsl:when test="$line = $marker">
<xsl:value-of select="$accumulator"/>
</xsl:when>
<xsl:when test="string-length($rest) = 0">
<xsl:value-of select="concat($accumulator, $line)"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="extract-until-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="$marker"/>
<xsl:with-param name="accumulator" select="concat($accumulator, $line, '&#10;')"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="skip-past-marker">
<xsl:param name="text"/>
<xsl:param name="marker"/>

<xsl:choose>
<xsl:when test="string-length($text) = 0"></xsl:when>
<xsl:otherwise>
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
<xsl:when test="$line = $marker">
<xsl:value-of select="$rest"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="skip-past-marker">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="marker" select="$marker"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

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
<xsl:choose>
<xsl:when test="string-length($remaining) = 0">
<xsl:value-of select="$accumulator"/>
</xsl:when>
<xsl:otherwise>
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
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="extract-content-from-first-header">
<xsl:param name="text"/>
<xsl:call-template name="skip-to-first-header">
<xsl:with-param name="remaining" select="$text"/>
</xsl:call-template>
</xsl:template>

<xsl:template name="skip-to-first-header">
<xsl:param name="remaining"/>
<xsl:choose>
<xsl:when test="string-length($remaining) = 0"></xsl:when>
<xsl:otherwise>
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
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- YAML processing templates -->
<xsl:template name="extract-yaml-title">
  <xsl:param name="text" />
  <xsl:choose>
    <xsl:when test="starts-with(normalize-space($text), '---')">
      <xsl:variable name="after-first-delimiter" select="substring-after($text, '---')" />
      <xsl:choose>
        <xsl:when test="contains($after-first-delimiter, '---')">
          <xsl:variable name="yaml-content" select="substring-before($after-first-delimiter, '---')" />
          <xsl:call-template name="parse-yaml-name">
            <xsl:with-param name="yaml" select="$yaml-content" />
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="parse-yaml-name">
  <xsl:param name="yaml" />
  <xsl:call-template name="find-yaml-name">
    <xsl:with-param name="remaining" select="$yaml" />
  </xsl:call-template>
</xsl:template>

<xsl:template name="find-yaml-name">
<xsl:param name="remaining"/>
<xsl:choose>
<xsl:when test="string-length($remaining) = 0">Nameless</xsl:when>
<xsl:otherwise>
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
</xsl:otherwise>
</xsl:choose>
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
<xsl:param name="in-triple-backticks-block" select="false()"/>
<xsl:choose>
<xsl:when test="string-length($text) = 0">false</xsl:when>
<xsl:otherwise>
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
<xsl:when test="starts-with($line, '```')">
<xsl:call-template name="check-for-headers">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-triple-backticks-block" select="not($in-triple-backticks-block)"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="starts-with($line, '#') and $in-triple-backticks-block = false()">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:when test="string-length($rest) > 0">
<xsl:call-template name="check-for-headers">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-triple-backticks-block" select="$in-triple-backticks-block"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="generate-heading-id">
<xsl:param name="text"/>
<xsl:call-template name="clean-slug">
<xsl:with-param name="text" select="normalize-space(translate($text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
</xsl:call-template>
</xsl:template>

<xsl:template name="process-inline">
<xsl:param name="text"/>
<xsl:choose>
<!-- Inline code -->
<xsl:when test="contains($text, '`')">
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
<!-- Footnotes ^[text] -->
<xsl:when test="contains($text, '^[') and contains(substring-after($text, '^['), ']')">
<xsl:value-of select="substring-before($text, '^[')"/>
<xsl:variable name="footnote-text" select="substring-before(substring-after($text, '^['), ']')"/>
<xsl:variable name="after-footnote" select="substring-after($text, ']')"/>
<label class="f-n">
<input type="checkbox" hidden="hidden" name="f-n"/>
<span></span>
<span><xsl:value-of select="$footnote-text"/></span>
</label>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-footnote"/>
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
<xsl:when test="normalize-space($alt-text) != ''">
<span class="img_w_alt">
<label>
<img src="../i/{$src}" alt="{$alt-text}"/>
<input name="i_a" type="checkbox" hidden="hidden"/>
<span></span>
<span><xsl:value-of select="$alt-text"/></span>
</label>
</span>
</xsl:when>
<xsl:otherwise>
<img src="../i/{$src}" alt=""/>
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
<!-- Wikilinks [[page]] or [[page|text]] -->
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
<!-- Strike-through -->
<xsl:when test="contains($text, '~~')">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '~~')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '~~')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '~~')">
<del>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($after-first, '~~')"/>
</xsl:call-template>
</del>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '~~')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>~~</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Bold -->
<xsl:when test="contains($text, '**')">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '**')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '**')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '**')">
<strong>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($after-first, '**')"/>
</xsl:call-template>
</strong>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '**')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>**</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Italic -->
<xsl:when test="contains($text, '*')">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($text, '*')"/>
</xsl:call-template>
<xsl:variable name="after-first" select="substring-after($text, '*')"/>
<xsl:choose>
<xsl:when test="contains($after-first, '*')">
<em>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-before($after-first, '*')"/>
</xsl:call-template>
</em>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="substring-after($after-first, '*')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:text>*</xsl:text>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-first"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!-- Line breaks -->
<xsl:when test="substring($text, string-length($text) - 1) = '  '">
<xsl:value-of select="substring($text, 1, string-length($text) - 2)"/>
<br/>
</xsl:when>
<!-- Raw URLs -->
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
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- TOC generation -->
<xsl:template name="generate-toc">
<xsl:param name="text"/>
<xsl:param name="in-triple-backticks-block" select="false()"/>
<xsl:choose>
<xsl:when test="string-length($text) = 0"></xsl:when>
<xsl:otherwise>
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
<xsl:when test="starts-with($line, '```')">
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-triple-backticks-block" select="not($in-triple-backticks-block)"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="starts-with($line, '#') and $in-triple-backticks-block = false()">
<xsl:variable name="heading-text" select="normalize-space(translate($line, '#', ''))"/>
<xsl:variable name="heading-id">
<xsl:call-template name="generate-heading-id">
<xsl:with-param name="text" select="$heading-text"/>
</xsl:call-template>
</xsl:variable>
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
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-triple-backticks-block" select="$in-triple-backticks-block"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="generate-toc">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="in-triple-backticks-block" select="$in-triple-backticks-block"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
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
<xsl:when test="starts-with($url, '#')">
<xsl:value-of select="substring-after($url, '#')"/>
</xsl:when>
<xsl:when test="contains($url, '#') and not(contains($url, '://'))">
<xsl:value-of select="substring-after($url, '#')"/>
</xsl:when>
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
<xsl:when test="starts-with($url, '#')">
<xsl:variable name="anchor-part" select="substring-after($url, '#')"/>
<xsl:variable name="processed-anchor">
<xsl:call-template name="make-wiki-url">
<xsl:with-param name="text" select="$anchor-part"/>
<xsl:with-param name="no-extension" select="true()"/>
</xsl:call-template>
</xsl:variable>
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
<xsl:when test="contains($url, '://')">
<a href="{$url}" tabindex="0"><xsl:value-of select="$final-link-text"/></a>
</xsl:when>
<xsl:when test="starts-with($url, '/') or starts-with($url, '../') or starts-with($url, './')">
<a href="{$url}" tabindex="0"><xsl:value-of select="$final-link-text"/></a>
</xsl:when>
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
<a href="{$processed-page}#{$processed-anchor}" title="{$page-part}" tabindex="0">
<xsl:value-of select="$final-link-text"/>
</a>
</xsl:when>
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

<xsl:template name="make-wiki-url">
<xsl:param name="text"/>
<xsl:param name="no-extension" select="false()"/>
<xsl:variable name="clean-slug">
<xsl:call-template name="clean-slug">
<xsl:with-param name="text" select="normalize-space($text)"/>
</xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test="$no-extension = true()">
<xsl:value-of select="$clean-slug"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat($clean-slug, '.xml')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="process-page-url">
<xsl:param name="url"/>
<xsl:choose>
<xsl:when test="contains($url, '.')">
<xsl:call-template name="make-wiki-url">
<xsl:with-param name="text" select="substring-before($url, '.')"/>
<xsl:with-param name="no-extension" select="true()"/>
</xsl:call-template>
<xsl:text>.</xsl:text>
<xsl:value-of select="substring-after($url, '.')"/>
</xsl:when>
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
<xsl:when test="starts-with($url, 'https://')">
<xsl:value-of select="substring-after($url, 'https://')"/>
</xsl:when>
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
<xsl:when test="contains($without-www, '/')">
<xsl:value-of select="substring-before($without-www, '/')"/>
</xsl:when>
<xsl:when test="contains($without-www, '#')">
<xsl:value-of select="substring-before($without-www, '#')"/>
</xsl:when>
<xsl:when test="substring($without-www, string-length($without-www) - 3) = '.xml'">
<xsl:value-of select="substring($without-www, 1, string-length($without-www) - 4)"/>
</xsl:when>
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
<xsl:variable name="char-before">
<xsl:if test="string-length($before-url) > 0">
<xsl:value-of select="substring($before-url, string-length($before-url))"/>
</xsl:if>
</xsl:variable>
<xsl:choose>
<xsl:when test="$char-before = '(' or $char-before = ']'">
<xsl:value-of select="$text"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$before-url"/>
</xsl:call-template>
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
<xsl:variable name="full-url" select="concat($protocol, $url-part)"/>
<a href="{$full-url}" tabindex="0"><xsl:value-of select="$full-url"/></a>
<xsl:variable name="after-url" select="substring-after($url-and-after, $url-part)"/>
<xsl:if test="string-length($after-url) > 0">
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="$after-url"/>
</xsl:call-template>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Table processing -->
<xsl:template name="parse-table-content">
<xsl:param name="content"/>
<xsl:variable name="trimmed">
<xsl:call-template name="trim-table-content">
<xsl:with-param name="text" select="normalize-space($content)"/>
</xsl:call-template>
</xsl:variable>
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
<xsl:variable name="before-row" select="substring-before($text, '[')"/>
<xsl:variable name="after-bracket" select="substring-after($text, '[')"/>
<xsl:variable name="row-content">
<xsl:call-template name="substring-before-unquoted">
<xsl:with-param name="text" select="$after-bracket"/>
<xsl:with-param name="delim" select="']'"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="after-row" select="substring-after($after-bracket, ']')"/>
<tr>
<xsl:call-template name="parse-table-cells">
<xsl:with-param name="text" select="$row-content"/>
<xsl:with-param name="is-header" select="$is-first"/>
</xsl:call-template>
</tr>
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
<xsl:when test="string-length($text)=0">
<xsl:value-of select="''"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="first" select="substring($text,1,1)"/>
<xsl:variable name="rest" select="substring($text,2)"/>
<xsl:choose>
<xsl:when test="$first='&quot;'">
<xsl:value-of select="$first"/>
<xsl:call-template name="substring-before-unquoted">
<xsl:with-param name="text" select="$rest"/>
<xsl:with-param name="delim" select="$delim"/>
<xsl:with-param name="in-string" select="not($in-string)"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="not($in-string) and $first=$delim">
</xsl:when>
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
<xsl:variable name="processed-content">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="$content"/>
</xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test="contains($processed-content, '&#10;&#10;')">
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$processed-content"/>
<xsl:with-param name="enable-sections" select="false()"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="contains($processed-content, '&#10;')">
<xsl:call-template name="process-lines-with-breaks">
<xsl:with-param name="text" select="$processed-content"/>
</xsl:call-template>
</xsl:when>
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
<xsl:variable name="current-line" select="substring-before($text, '&#10;')"/>
<xsl:variable name="remaining" select="substring-after($text, '&#10;')"/>
<xsl:call-template name="process-inline">
<xsl:with-param name="text" select="normalize-space($current-line)"/>
</xsl:call-template>
<xsl:text> </xsl:text>
<xsl:call-template name="process-lines-with-breaks">
<xsl:with-param name="text" select="$remaining"/>
</xsl:call-template>
</xsl:when>
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
<xsl:when test="contains($text, '\n')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\n'), '&#10;', substring-after($text, '\n'))"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="contains($text, '\r')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\r'), '&#13;', substring-after($text, '\r'))"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="contains($text, '\t')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\t'), '&#9;', substring-after($text, '\t'))"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="contains($text, '\\')">
<xsl:call-template name="unescape-json-string">
<xsl:with-param name="text" select="concat(substring-before($text, '\\'), '\', substring-after($text, '\\'))"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Utilities -->
<xsl:template name="clean-slug">
<xsl:param name="text"/>
<xsl:variable name="lowercase" select="translate($text, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
<xsl:variable name="alphanumeric-and-spaces" select="translate($lowercase, '.,!?;:()[]{}/', '----------')"/>
<xsl:variable name="with-single-dashes">
<xsl:call-template name="collapse-dashes">
<xsl:with-param name="text" select="translate($alphanumeric-and-spaces, ' ', '-')"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="trim-dashes">
<xsl:with-param name="text" select="$with-single-dashes"/>
</xsl:call-template>
</xsl:template>

<xsl:template name="collapse-dashes">
<xsl:param name="text"/>
<xsl:choose>
<xsl:when test="contains($text, '--')">
<xsl:call-template name="collapse-dashes">
<xsl:with-param name="text" select="concat(substring-before($text, '--'), '-', substring-after($text, '--'))"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="trim-dashes">
<xsl:param name="text"/>
<xsl:variable name="no-leading">
<xsl:choose>
<xsl:when test="starts-with($text, '-')">
<xsl:call-template name="trim-dashes">
<xsl:with-param name="text" select="substring($text, 2)"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="substring($no-leading, string-length($no-leading)) = '-'">
<xsl:value-of select="substring($no-leading, 1, string-length($no-leading) - 1)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$no-leading"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Mixed HTML content -->
<xsl:template name="serialize-mixed-content">
<xsl:param name="nodes"/>
<xsl:for-each select="$nodes">
<xsl:choose>
<xsl:when test="self::text()">
<xsl:call-template name="remove-yaml-frontmatter">
<xsl:with-param name="text" select="."/>
</xsl:call-template>
</xsl:when>
<xsl:when test="name() = 'html'">
<xsl:text>&#10;__HTML_BLOCK_</xsl:text>
<xsl:value-of select="generate-id(.)"/>
<xsl:text>_</xsl:text>
<xsl:choose>
<xsl:when test="@show">
<xsl:value-of select="@show"/>
</xsl:when>
<xsl:otherwise>render</xsl:otherwise>
</xsl:choose>
<xsl:text>__&#10;</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="serialize-mixed-content">
<xsl:with-param name="nodes" select="node()"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template name="process-mixed-text">
<xsl:param name="text"/>
<xsl:param name="enable-sections" select="false()"/>
<xsl:choose>
<xsl:when test="contains($text, '__HTML_BLOCK_')">
<xsl:variable name="before-html" select="substring-before($text, '__HTML_BLOCK_')"/>
<xsl:if test="normalize-space($before-html) != ''">
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$before-html"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:if>
<xsl:variable name="after-marker" select="substring-after($text, '__HTML_BLOCK_')"/>
<xsl:variable name="id-and-mode" select="substring-before($after-marker, '__')"/>
<xsl:variable name="block-id" select="substring-before($id-and-mode, '_')"/>
<xsl:variable name="display-mode" select="substring-after($id-and-mode, '_')"/>
<xsl:variable name="html-element" select="/*/html[generate-id(.) = $block-id]"/>
<xsl:choose>
<xsl:when test="$display-mode = 'code'">
  <pre><code>
    <xsl:variable name="html-content">
      <xsl:call-template name="serialize-html-content">
        <xsl:with-param name="nodes" select="$html-element/node()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="first-non-blank" 
                  select="string-length(substring-before($html-content, 
                          substring(normalize-space($html-content), 1, 1))) + 1"/>
    <xsl:value-of select="substring($html-content, $first-non-blank)"/>
  </code></pre>
</xsl:when>
<xsl:when test="$display-mode = 'both'">
<pre><code><xsl:call-template name="serialize-html-content">
<xsl:with-param name="nodes" select="$html-element/node()"/>
</xsl:call-template></code></pre>
<div class="rendered-output">
<xsl:copy-of select="$html-element/node()"/>
</div>
</xsl:when>
<xsl:otherwise>
<xsl:copy-of select="$html-element/node()"/>
</xsl:otherwise>
</xsl:choose>
<xsl:variable name="remaining" select="substring-after($after-marker, '__')"/>
<xsl:if test="normalize-space($remaining) != ''">
<xsl:call-template name="process-mixed-text">
<xsl:with-param name="text" select="$remaining"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:if>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="process-content">
<xsl:with-param name="text" select="$text"/>
<xsl:with-param name="enable-sections" select="$enable-sections"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="serialize-html-content">
<xsl:param name="nodes"/>
<xsl:for-each select="$nodes">
<xsl:choose>
<xsl:when test="self::text()">
<xsl:value-of select="."/>
</xsl:when>
<xsl:when test="self::*">
<xsl:text>&lt;</xsl:text>
<xsl:value-of select="name()"/>
<xsl:for-each select="@*">
<xsl:text> </xsl:text>
<xsl:value-of select="name()"/>
<xsl:text>="</xsl:text>
<xsl:value-of select="."/>
<xsl:text>"</xsl:text>
</xsl:for-each>
<xsl:text>&gt;</xsl:text>
<xsl:call-template name="serialize-html-content">
<xsl:with-param name="nodes" select="node()"/>
</xsl:call-template>
<xsl:text>&lt;/</xsl:text>
<xsl:value-of select="name()"/>
<xsl:text>&gt;</xsl:text>
</xsl:when>
</xsl:choose>
</xsl:for-each>
</xsl:template>

<xsl:template match="*">
<div class="markdown-error">
<p>Error processing Markdown content</p>
<pre><xsl:value-of select="."/></pre>
</div>
</xsl:template>

</xsl:stylesheet>