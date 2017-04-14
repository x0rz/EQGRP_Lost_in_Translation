<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:variable name="defaultColumnWidth" select="'20'"/>
	<xsl:variable name="maxWidth" select="'96'"/>

	<xsl:template match="Commands">
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Commands:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Cmd">
			<xsl:with-param name="columnWidth">
				<xsl:call-template name="FindWidth"/>
			</xsl:with-param>
		</xsl:apply-templates>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>- Loaded commands have a '*' preceeding the command name</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>For additional information try: help &lt;command&gt;</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

    <xsl:template match="Prefixes">
		<xsl:text>Prefixes:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Prefix">
			<xsl:with-param name="columnWidth">
				<xsl:call-template name="FindWidth"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

    <xsl:template match="Cmd">
		<xsl:param name="columnWidth"	select="$defaultColumnWidth"/>
		<xsl:variable name="columns"    select="floor( $maxWidth div ($columnWidth + 4) )"/>
		<xsl:if test="((position()-1) != 0) and ((position()-1) mod $columns = 0)">
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@loaded = 'true'">
				<xsl:text> *</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>  </xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="@name"/>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="($columnWidth+2) - string-length(@name)" /> 
		</xsl:call-template>

	</xsl:template>

	<xsl:template match="Prefix">
		<xsl:param name="columnWidth"	select="$defaultColumnWidth"/>
		<xsl:variable name="columns"    select="floor( $maxWidth div ($columnWidth + 4) )"/>
		<xsl:if test="((position()-1) != 0) and ((position()-1) mod $columns &lt; 1)">
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:text>  </xsl:text>

		<xsl:value-of select="@name"/>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="($columnWidth+2) - string-length(@name)" /> 
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="FindWidth">
		<xsl:param name="width" select="'10'"/>
		<xsl:param name="nodes" select="Prefix|Cmd"/>
		
		<xsl:choose>
			<xsl:when test="not($nodes)">
				<xsl:value-of select="$width"/>
			</xsl:when>
			<xsl:when test="string-length($nodes[position() = 1]/@name) &gt; $width">
				<xsl:call-template name="FindWidth">
					<xsl:with-param name="width" select="string-length($nodes[position() = 1]/@name)"/>
					<xsl:with-param name="nodes" select="$nodes[position() != 1]" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FindWidth">
					<xsl:with-param name="width" select="$width"/>
					<xsl:with-param name="nodes" select="$nodes[position() != 1]" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:transform>