<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Version">
	<xsl:text>Driver Version : </xsl:text>
	<xsl:value-of select="@major"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="@minor"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="@build"/>
	<xsl:call-template name="PrintReturn" />
  </xsl:template>

  <xsl:template match="Status">
	<xsl:text>Last Trigger Received : </xsl:text>
	<xsl:value-of select="substring-before(LastTriggerTime, 'T')"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="substring-after(LastTriggerTime, 'T')"/>
	<xsl:call-template name="PrintReturn" />
	
	<xsl:text>  Register Process Id : </xsl:text>
	<xsl:value-of select="RegisteredProcess/@pid"/>
	<xsl:call-template name="PrintReturn" />
		    
	<xsl:text>    Register Mailslot : </xsl:text>
	<xsl:value-of select="RegisteredProcess/@mailslot"/>
	<xsl:call-template name="PrintReturn" />
  </xsl:template>
  
</xsl:transform>