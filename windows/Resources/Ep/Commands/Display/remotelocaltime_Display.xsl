<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="RemoteLocalTime">
  <xsl:apply-templates select="Time" />
  <xsl:apply-templates select="TimeZone" />
  <xsl:apply-templates select="DaylightSavings" />
 </xsl:template>

 <xsl:template match="Time">
  <xsl:variable name="date"   select="substring-before(., 'T')" />
  <xsl:variable name="time"   select="substring-after (., 'T')" />

  <xsl:variable name="year"   select="substring-before($date, '-')"                       />
  <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
  <xsl:variable name="day"    select="substring-after(substring-after($date, '-'), '-')"  />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-after(substring-after($time, ':'), ':')"  />

  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Local Time&#x0D;&#x0A;----------&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Date : </xsl:text>
  <xsl:value-of select="concat($month, '/', $day, '/', $year)"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Time : </xsl:text>
  <xsl:value-of select="concat($hour, ':', $minute, ':', $second)"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="TimeZone">
  <xsl:variable name="Bias" select="substring-before(., ':')" />
  <xsl:text>Time Zone&#x0D;&#x0A;---------&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Bias : </xsl:text>
  <xsl:value-of select="Bias"/>
  <xsl:text> (hours:minutes)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Name : </xsl:text>
  <xsl:value-of select="Name"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="DaylightSavings">
  <xsl:variable name="Bias" select="substring-before(., ':')" />
  <xsl:text>Daylight Savings Time&#x0D;&#x0A;---------------------&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Bias : </xsl:text>
  <xsl:value-of select="Bias"/>
  <xsl:text> (hours:minutes)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Name : </xsl:text>
  <xsl:value-of select="Name"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>  Starts : </xsl:text>
  <xsl:value-of select="Start/Week"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="Start/Day"/>
  <xsl:text> in </xsl:text>
  <xsl:value-of select="Start/Month"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>    Ends : </xsl:text>
  <xsl:value-of select="End/Week"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="End/Day"/>
  <xsl:text> in </xsl:text>
  <xsl:value-of select="End/Month"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>