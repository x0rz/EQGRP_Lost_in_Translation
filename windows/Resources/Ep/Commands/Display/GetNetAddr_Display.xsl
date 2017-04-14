<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

    <xsl:template match="Local">
       Local Address - <xsl:value-of select="Address"/> : <xsl:value-of select="Port"/><xsl:text>
</xsl:text></xsl:template>

    <xsl:template match="LocalPeer">  Local Peer Address - <xsl:value-of select="Address"/> : <xsl:value-of select="Port"/><xsl:text>
</xsl:text></xsl:template>

    <xsl:template match="Remote">Remote Local Address - <xsl:value-of select="Address"/> : <xsl:value-of select="Port"/><xsl:text>
</xsl:text></xsl:template>

    <xsl:template match="RemotePeer"> Remote Peer Address - <xsl:value-of select="Address"/> : <xsl:value-of select="Port"/><xsl:text>
</xsl:text></xsl:template>

</xsl:transform>