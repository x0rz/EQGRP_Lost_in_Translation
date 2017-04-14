<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="StatusInfo">
		<xsl:apply-templates select="Status"/>
	</xsl:template>
	<xsl:template match="Status">
		<xsl:if test="(@index = 0) or (BoundProcess != 0)">
			<xsl:text>----------------------------------------------------------------</xsl:text>
			<xsl:call-template name="PrintReturn" />

			<xsl:text>                Index : </xsl:text>
			<xsl:value-of select="@index"/>
			<xsl:call-template name="PrintReturn" />

			<xsl:text>  Register Process Id : </xsl:text>
			<xsl:value-of select="BoundProcess"/>
			<xsl:call-template name="PrintReturn" />

			<xsl:text>    Register Mailslot : </xsl:text>
			<xsl:value-of select="Mailslot"/>
			<xsl:call-template name="PrintReturn" />

			<xsl:text>Last Trigger Received : </xsl:text>
			<xsl:value-of select="substring-before(LastTriggerTime, 'T')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring-before(substring-after(LastTriggerTime, 'T'), '.')"/>
			<xsl:call-template name="PrintReturn" />

			<xsl:text>  Last Trigger Status : </xsl:text>
			<xsl:value-of select="LastTriggerStatus/@value"/>
			<xsl:text> (</xsl:text>
			<xsl:value-of select="LastTriggerStatus"/>
			<xsl:text>)</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>
  
	<xsl:template match="Version">
		<xsl:text>Driver Version : </xsl:text>
		<xsl:value-of select="Major"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="Minor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="Fix"/>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="AdaptersInfo">
		<xsl:text> Filter Active : </xsl:text>
		<xsl:value-of select="@filterActive"/>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Thread Running : </xsl:text>
		<xsl:value-of select="@threadRunning"/>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>  Num Adapters : </xsl:text>
		<xsl:value-of select="@numAdapters"/>
		<xsl:call-template name="PrintReturn" />
		
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Adapters : </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>----------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="Adapter"/>
	</xsl:template>
	
	<xsl:template match="Adapter">
		<xsl:text>    </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
</xsl:transform>