<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Success">
    <xsl:text>Success</xsl:text>
    <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Version">
    <xsl:text>Version: </xsl:text>
    <xsl:value-of select="@major" />
    <xsl:text>.</xsl:text>
    <xsl:value-of select="@minor" />
    <xsl:text>.</xsl:text>
    <xsl:value-of select="@revision" />
    <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Device">
    <xsl:text>Device: '</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>' </xsl:text>
    <xsl:choose>
       <xsl:when test="contains(@isListening, 'true')">
         <xsl:text>(listening)</xsl:text>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text>(not listening)</xsl:text>
       </xsl:otherwise>
    </xsl:choose>
    <xsl:text>   Id: </xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:call-template name="PrintReturn" />
 </xsl:template>
 
 <xsl:template match="StoredConfiguration">
    <xsl:text>LogFile: </xsl:text>
    <xsl:value-of select="LogFile"/>
    <xsl:text> (</xsl:text>
    <xsl:choose>
		<xsl:when test="@maxSize &gt; 0">
			<xsl:text>maximum of </xsl:text>
			<xsl:value-of select="@maxSize" />
			<xsl:text> bytes</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>no maximum size</xsl:text>
		</xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
    <xsl:call-template name="PrintReturn" />
    <xsl:text>Connect to: </xsl:text>
    <xsl:call-template name="PrintReturn" />
    <xsl:for-each select="Device">
		<xsl:text>    </xsl:text>
		<xsl:value-of select="."/>
	    <xsl:call-template name="PrintReturn" />
    </xsl:for-each>
 </xsl:template>

</xsl:transform>