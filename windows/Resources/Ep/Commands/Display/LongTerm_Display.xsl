<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Success">
	<xsl:call-template name="PrintReturn"/>
	<xsl:text>The operation completed successfully.</xsl:text>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="LongTermPlugins">
	<xsl:apply-templates select="LoadPlugin"/>
  </xsl:template>

  <xsl:template match="Plugins">
The following plugins are stored on the remote side:
  ID    R_XSUM  L_XSUM   R_SIZE   L_SIZE     STATUS      REMOTE_FILE
----------------------------------------------------------------------
<xsl:apply-templates select="Plugin"/>
</xsl:template>

    <xsl:template match="LoadPlugin">
	<xsl:text>Plugin </xsl:text>
	<xsl:value-of select="@id"/>
	<xsl:call-template name="PrintReturn"/>
	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>
	<xsl:value-of select="@status"/>
	<xsl:call-template name="PrintReturn"/>
    </xsl:template>

    <xsl:template match="Plugin">
	<xsl:text> </xsl:text>
	<xsl:value-of select="@id"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:value-of select="@remotechecksum"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:value-of select="@localchecksum"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:value-of select="format-number(@remotesize, '000,000')"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

	<xsl:value-of select="format-number(@localsize, '000,000')"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

        <xsl:choose>
          <xsl:when test="@remotechecksum = '0x0000'">
            <xsl:text> REMOTE_BAD  </xsl:text>
          </xsl:when>
	  <xsl:when test="@remotechecksum != @localchecksum">
            <xsl:text>SUM MISMATCH </xsl:text>
          </xsl:when>
	  <xsl:when test="@remotesize != @localsize">
            <xsl:text>SIZE MISMATCH</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>    GOOD     </xsl:text>
          </xsl:otherwise>
        </xsl:choose>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="2"/>
	</xsl:call-template>

        <xsl:value-of select="."/>

	<xsl:text>&#x0D;&#x0A;</xsl:text>
    </xsl:template>

</xsl:transform>