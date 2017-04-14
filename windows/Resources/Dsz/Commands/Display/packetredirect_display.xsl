<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="LocalSocket">
		<xsl:text>Local socket listening on </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="@port"/>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>

    <xsl:template match="NewConnection">
		<xsl:text>New connection received from </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:text> : </xsl:text>
		<xsl:value-of select="@port"/>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>

    <xsl:template match="NewPacket">
		<xsl:text>New packet indication received (</xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:text> bytes)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>

	<xsl:template match="PacketData">
		<xsl:text>Sending packet (</xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:text> bytes)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>

    <xsl:template match="PacketSent">
		<xsl:text>Packet sent</xsl:text>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>

    <xsl:template match="ConnectionClosed">
		<xsl:text>Local connection closed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
    </xsl:template>


</xsl:transform>