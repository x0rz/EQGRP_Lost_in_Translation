<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

    <xsl:template match="LocalSocket">
	<xsl:text>Local socket listening on </xsl:text>
	<xsl:value-of select="@address"/>
	<xsl:text> : </xsl:text>
	<xsl:value-of select="@port"/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
    </xsl:template>

    <xsl:template match="NewConnection">
	<xsl:text>New connection received from </xsl:text>
	<xsl:value-of select="@address"/>
	<xsl:text> : </xsl:text>
	<xsl:value-of select="@port"/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
    </xsl:template>

    <xsl:template match="NewPacket">
	<xsl:text>New packet indication received (</xsl:text>
	<xsl:value-of select="@size"/>
	<xsl:text> bytes)&#x0D;&#x0A;</xsl:text>
    </xsl:template>

    <xsl:template match="PacketData">
	<xsl:text>Sending packet (</xsl:text>
	<xsl:value-of select="@size"/>
	<xsl:text> bytes)&#x0D;&#x0A;</xsl:text>
    </xsl:template>

    <xsl:template match="PacketSent">
	<xsl:text>Packet sent&#x0D;&#x0A;</xsl:text>
    </xsl:template>

    <xsl:template match="ConnectionClosed">
	<xsl:text>Local connection closed&#x0D;&#x0A;</xsl:text>
    </xsl:template>

</xsl:transform>