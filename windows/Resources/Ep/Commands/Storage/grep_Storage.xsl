<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="File"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="File">
   <xsl:choose>
    <xsl:when test="@denied or not(Line)">
     <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">file_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@location"/></xsl:attribute>
     </xsl:element>
     <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">file_open_ok</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@denied"/></xsl:attribute>
     </xsl:element>
     <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">line_position</xsl:attribute>
      <xsl:attribute name="value">0</xsl:attribute>
     </xsl:element>
     <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">line_data</xsl:attribute>
      <xsl:attribute name="value"></xsl:attribute>
     </xsl:element>
    </xsl:when>
    <xsl:otherwise>
     <xsl:for-each select="Line">
      <xsl:element name="Storage">
       <xsl:attribute name="type">string</xsl:attribute>
       <xsl:attribute name="name">file_name</xsl:attribute>
       <xsl:attribute name="value"><xsl:value-of select="../@location"/></xsl:attribute>
      </xsl:element>
      <xsl:element name="Storage">
       <xsl:attribute name="type">bool</xsl:attribute>
       <xsl:attribute name="name">file_open_ok</xsl:attribute>
       <xsl:attribute name="value">true</xsl:attribute>
      </xsl:element>
      <xsl:element name="Storage">
       <xsl:attribute name="type">int</xsl:attribute>
       <xsl:attribute name="name">line_position</xsl:attribute>
       <xsl:attribute name="value"><xsl:value-of select="@position" /></xsl:attribute>
      </xsl:element>
      <xsl:element name="Storage">
       <xsl:attribute name="type">string</xsl:attribute>
       <xsl:attribute name="name">line_data</xsl:attribute>
       <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
      </xsl:element>
     </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

</xsl:transform>