<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Channels">
The following Channels are currently in Use:
   ID     COMMAND     SENT          RECEIVED     FUNCTIONPOINTER  FLAGS
<xsl:apply-templates select="Channel"/>
    </xsl:template>

    <xsl:template match="Channel">
	<xsl:text> </xsl:text>
	<xsl:value-of select="format-number(@request, '0000000')"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

        <xsl:value-of select="format-number(@commandRequest, '0000000')"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:apply-templates select="Sent"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:apply-templates select="Received"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

	<xsl:value-of select="Function"/>

        <xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="6"/>
	</xsl:call-template>

        <xsl:if test="Released">
	    <xsl:text>R</xsl:text>
        </xsl:if>
        <xsl:if test="Local">
	    <xsl:text>L</xsl:text>
        </xsl:if>

	<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="Sent">   <xsl:value-of select="format-number(@total, '00000000')"/>(<xsl:value-of select="format-number(@ratio, '00')"/>%)</xsl:template>

    <xsl:template match="Received">   <xsl:value-of select="format-number(@total, '00000000')"/>(<xsl:value-of select="format-number(@ratio, '00')"/>%)</xsl:template>

</xsl:transform>