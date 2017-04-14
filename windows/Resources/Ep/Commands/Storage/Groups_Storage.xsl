<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Group"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Group">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">group_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@group_id"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">group</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@group"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">comment</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@comment"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">attributes</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Attributes/@mask"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_mandatory</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Attributes/SeGroupMandatory">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_enabled</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Attributes/SeGroupEnabled">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_enabled_by_default</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Attributes/SeGroupEnabledByDefault">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

</xsl:transform>