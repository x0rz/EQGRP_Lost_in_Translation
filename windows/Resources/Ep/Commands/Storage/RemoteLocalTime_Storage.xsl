<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="RemoteLocalTime"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="RemoteLocalTime">

    <xsl:variable name="date"   select="substring-before(Time, 'T')" />
    <xsl:variable name="time"   select="substring-after (Time, 'T')" />

    <xsl:variable name="year"   select="substring-before($date, '-')"                       />
    <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
    <xsl:variable name="day"    select="substring-after(substring-after($date, '-'), '-')"  />
    <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
    <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
    <xsl:variable name="second" select="substring-after(substring-after($time, ':'), ':')"  />

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remoteDate</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="concat($month, '/', $day, '/', $year)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remoteTime</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="concat($hour, ':', $minute, ':', $second)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remoteZone</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="TimeZone/Name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remoteBias</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="substring-before(TimeZone/Bias, ':')*60 + substring-after(TimeZone/Bias, ':')" /></xsl:attribute>
    </xsl:element>

    <!-- Daylight Savings Time Stuff -->
    <xsl:choose>
	<xsl:when test="DaylightSavings">
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">bool</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavings</xsl:attribute>
		<xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsBias</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="substring-before(DaylightSavings/Bias, ':')*60 + substring-after(DaylightSavings/Bias, ':')" /></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">string</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsName</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/Name"/></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsStartDay</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/Start/Day/@value"/></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsStartWeek</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/Start/Week/@value"/></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsStartMonth</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/Start/Month/@value"/></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsEndDay</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/End/Day/@value"/></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsEndWeek</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/End/Week/@value"/></xsl:attribute>
	    </xsl:element>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">int</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavingsEndMonth</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="DaylightSavings/End/Month/@value"/></xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	        <xsl:attribute name="type">bool</xsl:attribute>
	        <xsl:attribute name="name">DaylightSavings</xsl:attribute>
		<xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>