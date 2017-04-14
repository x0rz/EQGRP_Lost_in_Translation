<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Element">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:apply-templates select="Attribute"/>
		<xsl:text>&gt;</xsl:text>
		
		<xsl:choose>
			<xsl:when test="Text">
				<xsl:apply-templates select="Text"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintReturn"/>
			</xsl:otherwise>	
		</xsl:choose>
		
		<xsl:apply-templates select="Element"/>
		
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>&gt;</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Attribute">
		<xsl:text> </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="@value"/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
	<xsl:template match="Text">
		<xsl:value-of select="."/>
	</xsl:template>
</xsl:transform>