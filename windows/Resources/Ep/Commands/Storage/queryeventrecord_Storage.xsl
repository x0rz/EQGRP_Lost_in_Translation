<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Events"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Events"> 
   <xsl:apply-templates select="Event" />
  </xsl:template>


  <xsl:template match="Event">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">record_number</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@recordNumber" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">event_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@eventType" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">event_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@code" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">time_stamp</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDYHMS">
        <xsl:with-param name="i" select="WriteTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">computer</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@computer" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@sid" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">source</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@source" /></xsl:attribute>
    </xsl:element>

    <xsl:apply-templates select="String" />
    <xsl:apply-templates select="Data" />
  </xsl:template>

  <xsl:template match="String">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">string_rec_num</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@recordNumber" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">strings</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Data">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">data_rec_num</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@recordNumber" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">data</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>