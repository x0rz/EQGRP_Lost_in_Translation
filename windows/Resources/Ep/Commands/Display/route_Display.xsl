<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Interfaces">
   <xsl:text>============================================================================</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:text>Interface List</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:apply-templates select="Interface" />
   <xsl:text>============================================================================</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

  <xsl:template match="Interface">
   <xsl:value-of select="@index" />
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="11 - string-length(@index)" />
   </xsl:call-template>
   <xsl:value-of select="PhysAddr" />
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="17 - string-length(PhysAddr)" />
   </xsl:call-template>
   <xsl:text>  </xsl:text>
   <xsl:value-of select="Description" />
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

  <xsl:template match="Routes">
   <xsl:text>============================================================================</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:text>Active Routes:</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:text>Network Destination        Netmask          Gateway        Interface Metric1</xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:apply-templates select="Route" />
   <xsl:text>============================================================================</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

  <xsl:template match="Route">
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="17 - string-length(@destination)" />
   </xsl:call-template>
   <xsl:value-of select="@destination" />
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="17 - string-length(@mask)" />
   </xsl:call-template>
   <xsl:value-of select="@mask" />
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="17 - string-length(@gateway)" />
   </xsl:call-template>
   <xsl:value-of select="@gateway" />
   <xsl:choose>
	<xsl:when test="@ip">
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="17-string-length(@ip)" />
		</xsl:call-template>
		<xsl:value-of select="@ip" />
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="17-string-length(@interfaceIndex)" />
		</xsl:call-template>
		<xsl:value-of select="@interfaceIndex" />
	</xsl:otherwise>
   </xsl:choose>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="7" />
   </xsl:call-template>
   <xsl:value-of select="@metric1" />
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

</xsl:transform>