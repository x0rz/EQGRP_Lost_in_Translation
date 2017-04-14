<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="AtJob"/>
            <xsl:apply-templates select="NetJob" />
            <xsl:apply-templates select="NewJob" />
	</xsl:element>
  </xsl:template>

  <xsl:template match="AtJob">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">cmd</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="CommandText"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">frequency</xsl:attribute>
      <xsl:choose>
        <xsl:when test="Flags/JobRunsToday">
          <xsl:attribute name="value">Today</xsl:attribute>
        </xsl:when>
        <xsl:when test="Flags/JobRunPeriodically">
          <xsl:attribute name="value">Each</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">Next</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">at_time</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Time"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="NetJob">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">next_run_date</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDY">
        <xsl:with-param name="i" select="NextRun/." />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">next_run_time</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeHMS">
        <xsl:with-param name="i" select="NextRun/." />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">account_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Account"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">application_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Application"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">parameters</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Parameters"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="NewJob">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>