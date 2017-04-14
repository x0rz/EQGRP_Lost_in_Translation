<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="ExecuteOptions">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">value</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">ExecutionDisabled</xsl:attribute>
      <xsl:choose>
	<xsl:when test="ExecutionDisabled">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">ExecutionEnabled</xsl:attribute>
      <xsl:choose>
	<xsl:when test="ExecutionEnabled">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">DisableThunkEmulation</xsl:attribute>
      <xsl:choose>
	<xsl:when test="DisableThunkEmulation">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">Permanent</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Permanent">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">ExecuteDispatchEnabled</xsl:attribute>
      <xsl:choose>
	<xsl:when test="ExecuteDispatchEnabled">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">ImageDispatchEnabled</xsl:attribute>
      <xsl:choose>
	<xsl:when test="ImageDispatchEnabled">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  </xsl:template>

</xsl:transform>