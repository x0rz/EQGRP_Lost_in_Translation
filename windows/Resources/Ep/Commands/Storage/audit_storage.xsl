<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Status"/>
	    <xsl:apply-templates select="ON"/>
	    <xsl:apply-templates select="OFF"/>
	    <xsl:apply-templates select="Audit"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Audit">
   <xsl:element name="Storage">
    <xsl:attribute name="type">bool</xsl:attribute>
    <xsl:attribute name="name">audit_mode</xsl:attribute>
    <xsl:attribute name="value">false</xsl:attribute>
   </xsl:element>
   <xsl:element name="Storage">
    <xsl:attribute name="type">bool</xsl:attribute>
    <xsl:attribute name="name">audit_status_avail</xsl:attribute>
    <xsl:attribute name="value">false</xsl:attribute>
   </xsl:element>
  </xsl:template>

  <xsl:template match="Status">
   <xsl:element name="Storage">
    <xsl:attribute name="type">bool</xsl:attribute>
    <xsl:attribute name="name">audit_mode</xsl:attribute>
    <xsl:choose>
     <xsl:when test="contains(@current, 'ON')">
      <xsl:attribute name="value">true</xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="value">false</xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">bool</xsl:attribute>
    <xsl:attribute name="name">audit_status_avail</xsl:attribute>
    <xsl:attribute name="value">true</xsl:attribute>
   </xsl:element>

   <xsl:apply-templates select="Event"/>

  </xsl:template>

  <xsl:template match="Event">
   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">audit_category</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@category" /></xsl:attribute>
   </xsl:element>
   <xsl:element name="Storage">
    <xsl:attribute name="type">bool</xsl:attribute>
    <xsl:attribute name="name">audit_event_success</xsl:attribute>
    <xsl:choose>
     <xsl:when test="OnSuccess">
      <xsl:attribute name="value">true</xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="value">false</xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:element>
   <xsl:element name="Storage">
    <xsl:attribute name="type">bool</xsl:attribute>
    <xsl:attribute name="name">audit_event_failure</xsl:attribute>
    <xsl:choose>
     <xsl:when test="OnFailure">
      <xsl:attribute name="value">true</xsl:attribute>
     </xsl:when>
     <xsl:otherwise>
      <xsl:attribute name="value">false</xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:element>
  </xsl:template>
</xsl:transform>