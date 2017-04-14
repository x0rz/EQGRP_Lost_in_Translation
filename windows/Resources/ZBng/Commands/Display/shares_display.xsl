<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:variable name="status" select="14"/>
	<xsl:variable name="local"  select="10"/>
	<xsl:variable name="remote" select="26"/>
	
	<xsl:template match="MapResponse">
		<xsl:text>Mapped </xsl:text>
		<xsl:value-of select="ResourcePath"/>
		<xsl:if test="ResourceName">
			<xsl:text> to </xsl:text>
			<xsl:value-of select="ResourceName"/>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
  
	<xsl:template match="Shares">
		<xsl:call-template name="PrintString">
			<xsl:with-param name="string" select="'Status'"/>
			<xsl:with-param name="space" select="$status" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="string" select="'Local'"/>
			<xsl:with-param name="space" select="$local" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="string" select="'Remote'"/>
			<xsl:with-param name="space" select="$remote" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="CharFill">
			<xsl:with-param name="i" select="$status + $local + $remote"/>
			<xsl:with-param name="char" select="'-'" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Share"/>
	</xsl:template>
	
	<xsl:template match="Share">
		<xsl:call-template name="PrintString">
			<xsl:with-param name="string" select="Status"/>
			<xsl:with-param name="space" select="$status" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="string" select="LocalName"/>
			<xsl:with-param name="space" select="$local" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="string" select="RemoteName"/>
			<xsl:with-param name="space" select="$remote" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="QueryResponse">
		<xsl:text>Available shares:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Resource"/>
	</xsl:template>
	<xsl:template match="Resource">
		<xsl:value-of select="Name"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Type"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="Caption"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="Path">
			<xsl:call-template name="PrintTab"/>
			<xsl:value-of select="Path"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="PrintString">
		<xsl:param name="string"/>
		<xsl:param name="space"/>
		
		<xsl:value-of select="$string"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="$space - string-length($string)"/>
		</xsl:call-template>
	</xsl:template>
	
</xsl:transform>
