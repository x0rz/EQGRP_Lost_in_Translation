<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Processes"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Processes">
   <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="Process">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:call-template name="StripPath">
        <xsl:with-param name="path" select="."/>
      </xsl:call-template>


    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:element>

  </xsl:template>

<!-- Functions -->
  <xsl:template name="StripPath">
    <xsl:param name="path"/>
    <xsl:choose>
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="StripPath">
          <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:attribute name="value"><xsl:value-of select="$path"/></xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>