<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Commands">
The following Commands are currently in use:
   ID       SENT           RECEIVED    FLAGS      COMMAND
<xsl:apply-templates select="Cmd"/>
</xsl:template>

  <xsl:template match="Channels">
The following Channels are currently in use:
   ID     COMMAND     SENT          RECEIVED     FLAGS
<xsl:apply-templates select="Channel"/>
</xsl:template>

    <xsl:template match="Cmd">
	<xsl:text> </xsl:text>
	<xsl:value-of select="format-number(@request, '0000000')"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:apply-templates select="Sent"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:apply-templates select="Received"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

        <xsl:choose>
          <xsl:when test="Asynchronous">
            <xsl:text>A</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="Released">
            <xsl:text>R</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

	<xsl:value-of select="CommandLine"/>

	<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="Total">
Total bytes received : <xsl:value-of select="format-number(Received, '000,000,000')"/>
    Total bytes sent : <xsl:value-of select="format-number(Sent, '000,000,000')"/>
	<xsl:text>
</xsl:text>
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