<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="EventLog"/>
	    <xsl:apply-templates select="ErrLog"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="EventLog">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">qeLastMod</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDYHMS">
        <xsl:with-param name="i" select="WriteTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">qeLogName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeRecordCount</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@numRecords" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeOldest</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@oldestRecordNum" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeNewest</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@mostRecentRecordNum" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeErr</xsl:attribute>
      <xsl:attribute name="value">0</xsl:attribute>
    </xsl:element>



  </xsl:template>

  <xsl:template match="ErrLog">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">qeLastMod</xsl:attribute>
      <xsl:attribute name="value">0</xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">qeLogName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeRecordCount</xsl:attribute>
      <xsl:attribute name="value">0</xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeOldest</xsl:attribute>
      <xsl:attribute name="value">0</xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeNewest</xsl:attribute>
      <xsl:attribute name="value">0</xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">qeErr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@osError" /></xsl:attribute>
    </xsl:element>



  </xsl:template>

</xsl:transform>