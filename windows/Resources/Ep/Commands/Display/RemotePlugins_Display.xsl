<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Plugins">
The following Plugins are currently loaded REMOTELY:
  ID     HANDLE   VERSION         FILE (if any)
----------------------------------------------------------------------
<xsl:apply-templates select="Plugin"/>
</xsl:template>

    <xsl:template match="Plugin">
	<xsl:text> </xsl:text>
	<xsl:value-of select="@id"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

        <xsl:choose>
          <xsl:when test="number(@handle) = 0">
            <xsl:text>  CORE  </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@handle"/>
          </xsl:otherwise>
        </xsl:choose>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="3"/>
	</xsl:call-template>

	<xsl:value-of select="@major"/>.<xsl:value-of select="@minor"/>.<xsl:value-of select="@build"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

        <xsl:value-of select="."/>

	<xsl:text>
</xsl:text>
    </xsl:template>

</xsl:transform>