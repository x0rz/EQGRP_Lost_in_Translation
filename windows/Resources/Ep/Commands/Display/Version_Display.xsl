<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

    <xsl:template match="ListeningPost">
	<xsl:text>Listening Post :</xsl:text>
	<xsl:call-template name="PrintReturn"/>

	<xsl:text>    Compiled : </xsl:text>
	<xsl:value-of select="Compiled"/>
	<xsl:call-template name="PrintReturn"/>

	<xsl:text>        Base : </xsl:text>
	<xsl:value-of select="Base"/>
	<xsl:call-template name="PrintReturn"/>

	<xsl:text>     Plugins : </xsl:text>
	<xsl:value-of select="Plugins"/>
	<xsl:call-template name="PrintReturn"/>
	<xsl:call-template name="PrintReturn"/>
    </xsl:template>

    <xsl:template match="Implant">
	<xsl:text>Implant : </xsl:text>
	<xsl:call-template name="PrintReturn"/>
	
	<xsl:text>    Compiled : </xsl:text>
	<xsl:value-of select="@major"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="@minor"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="@build"/>
        <xsl:call-template name="PrintReturn"/>
    </xsl:template>

   <xsl:template match="Success">
	<xsl:call-template name="PrintReturn"/>
   </xsl:template>

</xsl:transform>