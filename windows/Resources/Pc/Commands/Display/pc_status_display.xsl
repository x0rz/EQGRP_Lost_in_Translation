<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="PcStatus">
		<xsl:text>        Version : </xsl:text>
		<xsl:value-of select="@versionMajor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@versionMinor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@versionBuild"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>             Id : </xsl:text>
		<xsl:value-of select="@pcId"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   Segment Name : </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Trigger Type(s) : </xsl:text>
		<xsl:value-of select="Trigger/@type"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Trigger Status : </xsl:text>
		<xsl:value-of select="Trigger/@status"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Triggers Recv'd : </xsl:text>
		<xsl:value-of select="Trigger/@numReceived"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>   Last Trigger : </xsl:text>
		<xsl:value-of select="substring-before(Trigger/LastReceived, 'T')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Trigger/LastReceived, 'T'), '.')"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>