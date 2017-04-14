<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml"/>


 <xsl:template name="printTimeMDYHMS">
  <xsl:param name="i" />
  <xsl:variable name="date"   select="substring-before($i, 'T')"                          />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="year"   select="substring-before($date, '-')"                       />
  <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
  <xsl:variable name="day"    select="substring-after (substring-after($date, '-'), '-')" />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-after (substring-after($time, ':'), ':')" />
  <xsl:value-of select="$month" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$day" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$year" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="$hour" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$minute" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$second" />

 </xsl:template>

 <xsl:template name="printTimeMDY">
  <xsl:param name="i" />
  <xsl:variable name="date"   select="substring-before($i, 'T')"                          />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="year"   select="substring-before($date, '-')"                       />
  <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
  <xsl:variable name="day"    select="substring-after (substring-after($date, '-'), '-')" />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-after (substring-after($time, ':'), ':')" />
  <xsl:value-of select="$month" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$day" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$year" />
 </xsl:template>


 <xsl:template name="printTimeHMS">
  <xsl:param name="i" />
  <xsl:variable name="date"   select="substring-before($i, 'T')"                          />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="year"   select="substring-before($date, '-')"                       />
  <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
  <xsl:variable name="day"    select="substring-after (substring-after($date, '-'), '-')" />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-after (substring-after($time, ':'), ':')" />
  <xsl:value-of select="$hour" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$minute" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$second" />

 </xsl:template>



</xsl:transform>